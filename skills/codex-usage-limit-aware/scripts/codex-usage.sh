#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: codex-usage.sh [--all] [--json]

Show the newest valid Codex usage snapshot recorded in local sessions.

  --all   include other recorded limit families
  --json  emit compact, normalized JSON
  -h, --help
EOF
}

show_all=false
json_output=false

while (($#)); do
    case "$1" in
        --all) show_all=true ;;
        --json) json_output=true ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'error: unknown argument: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

command -v jq >/dev/null 2>&1 || {
    echo "error: jq is required" >&2
    exit 1
}

codex_dir="${CODEX_HOME:-${HOME}/.codex}"
sessions_dir="$codex_dir/sessions"

[[ -d "$sessions_dir" ]] || {
    printf 'error: Codex sessions directory not found: %s\n' "$sessions_dir" >&2
    exit 1
}

snapshot_file="$(mktemp "${TMPDIR:-/tmp}/codex-usage.XXXXXX")"
normalized_file="${snapshot_file}.normalized"
trap 'rm -f -- "$snapshot_file" "$normalized_file"' EXIT

stream_session_lines() {
    local status

    if command -v rg >/dev/null 2>&1; then
        set +e
        rg --hidden --no-ignore --glob '*.jsonl' --no-heading --no-filename \
            --fixed-strings '"rate_limits"' "$sessions_dir"
        status=$?
        set -e
        ((status == 0 || status == 1)) || return "$status"
    else
        find "$sessions_dir" -type f -name '*.jsonl' -exec cat -- {} +
    fi
}

# Parse line-by-line so an actively written, truncated JSONL record cannot poison
# the whole scan. Select the newest valid snapshot for each limit family by the
# event timestamp rather than by thread identity or file modification time.
stream_session_lines | jq -Rn '
    def timestamp_epoch:
        try (sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601) catch null;
    def valid_window:
        type == "object"
        and (.used_percent | type) == "number"
        and (.window_minutes | type) == "number"
        and .window_minutes > 0
        and (.resets_at | type) == "number";

    [
        inputs
        | fromjson?
        | select((.timestamp | type) == "string")
        | select((.payload.rate_limits | type) == "object")
        | (.timestamp | timestamp_epoch) as $timestamp_epoch
        | select($timestamp_epoch != null)
        | .payload.rate_limits as $limit
        | {
            timestamp,
            timestamp_epoch: $timestamp_epoch,
            id: ($limit.limit_id // ""),
            name: $limit.limit_name,
            plan: $limit.plan_type,
            windows: [
                $limit.primary,
                $limit.secondary
                | select(valid_window)
            ],
            credits: $limit.credits,
            individual_limit: $limit.individual_limit,
            spend_control_reached: $limit.spend_control_reached,
            rate_limit_reached_type: $limit.rate_limit_reached_type
        }
        | select(.id != "" and (.windows | length) > 0)
    ]
    | group_by([.id, (.name // "")])
    | map(max_by(.timestamp_epoch) | del(.timestamp_epoch))
    | sort_by(if .id == "codex" then "" else .id end, (.name // ""))
' >"$snapshot_file"

now_epoch="$(date +%s)"
reset_buffer_seconds=10

# Normalize the output once so the human and JSON renderers share exactly the
# same selection, validation, and calculations.
jq --argjson now "$now_epoch" --argjson buffer "$reset_buffer_seconds" \
    --argjson show_all "$show_all" '
    def timestamp_epoch:
        try (sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601) catch null;
    def clamp_percent:
        if . < 0 then 0 elif . > 100 then 100 else . end;
    def window_label:
        if . % 10080 == 0 then "\(. / 10080 | floor)w"
        elif . % 1440 == 0 then "\(. / 1440 | floor)d"
        elif . % 60 == 0 then "\(. / 60 | floor)h"
        else "\(. | floor)m"
        end;

    {
        generated_at: $now,
        reset_buffer_seconds: $buffer,
        limits: [
            .[]
            | select($show_all or .id == "codex")
            | .timestamp as $timestamp
            | ($timestamp | timestamp_epoch) as $snapshot_epoch
            | {
                id,
                name,
                plan,
                snapshot_at: $timestamp,
                snapshot_age_seconds: (
                    if $snapshot_epoch == null then null
                    else $now - $snapshot_epoch
                    end
                ),
                windows: [
                    .windows[]
                    | {
                        label: (.window_minutes | window_label),
                        window_minutes,
                        used_percent,
                        left_percent: ((100 - .used_percent) | clamp_percent),
                        resets_at,
                        reset_in_seconds: (.resets_at - $now),
                        wait_seconds: (
                            if (.resets_at - $now + $buffer) > 0
                            then .resets_at - $now + $buffer
                            else 0
                            end
                        ),
                        status: (
                            if .resets_at > $now then "active"
                            elif (.resets_at + $buffer) > $now then "buffering"
                            else "stale"
                            end
                        )
                    }
                ],
                credits,
                individual_limit,
                spend_control_reached,
                rate_limit_reached_type
            }
        ]
    }
' "$snapshot_file" >"$normalized_file"
mv -- "$normalized_file" "$snapshot_file"

limit_count="$(jq '.limits | length' "$snapshot_file")"
if ((limit_count == 0)); then
    if [[ "$show_all" == true ]]; then
        echo "error: no valid usage snapshot found" >&2
    else
        echo "error: no valid Codex usage snapshot found (try --all)" >&2
    fi
    exit 1
fi

if [[ "$json_output" == true ]]; then
    jq -c . "$snapshot_file"
    exit 0
fi

format_duration() {
    local total="$1" days hours minutes

    ((total < 0)) && total=$((-total))
    if ((total < 60)); then
        printf '%ss' "$total"
    elif ((total < 3600)); then
        printf '%sm' "$((total / 60))"
    elif ((total < 86400)); then
        hours=$((total / 3600))
        minutes=$(((total % 3600) / 60))
        printf '%sh' "$hours"
        ((minutes > 0)) && printf '%sm' "$minutes"
    else
        days=$((total / 86400))
        hours=$(((total % 86400) / 3600))
        printf '%sd' "$days"
        ((hours > 0)) && printf '%sh' "$hours"
    fi
}

format_percent() {
    jq -nr --argjson value "$1" '
        if ($value | floor) == $value then "\($value | floor)"
        else "\($value * 10 | round / 10)"
        end
    '
}

for ((limit_index = 0; limit_index < limit_count; limit_index++)); do
    IFS=$'\x1f' read -r limit_id limit_name plan snapshot_at snapshot_age \
        has_credits unlimited balance spend_reached reached_type < <(
        jq -r --argjson i "$limit_index" '
            .limits[$i]
            | [
                .id,
                (.name // ""),
                (.plan // ""),
                .snapshot_at,
                (.snapshot_age_seconds // ""),
                (.credits.has_credits // false),
                (.credits.unlimited // false),
                (.credits.balance // ""),
                (.spend_control_reached // false),
                (.rate_limit_reached_type // "")
            ]
            | join("\u001f")
        ' "$snapshot_file"
    )

    display_name="$limit_id"
    if [[ "$limit_id" != "codex" && -n "$limit_name" ]]; then
        display_name="$limit_name"
    fi

    snapshot_display="$(date -d "$snapshot_at" '+%m-%d %H:%M' 2>/dev/null || printf '%s' "$snapshot_at")"
    if [[ -z "$snapshot_age" ]]; then
        age_display="age unknown"
    elif ((snapshot_age < 0)); then
        age_display="clock +$(format_duration "$snapshot_age")"
    elif ((snapshot_age <= 1)); then
        age_display="now"
    else
        age_display="$(format_duration "$snapshot_age") ago"
    fi

    printf '%s' "$display_name"
    [[ -n "$plan" ]] && printf ' %s' "$plan"
    printf ' | snapshot %s (%s)' "$snapshot_display" "$age_display"

    if [[ "$unlimited" == true ]]; then
        printf ' | credits unlimited'
    elif [[ "$has_credits" == true || ( -n "$balance" && "$balance" != "0" ) ]]; then
        printf ' | credits %s' "${balance:-available}"
    fi
    [[ "$spend_reached" == true ]] && printf ' | spend limit reached'
    [[ -n "$reached_type" ]] && printf ' | limited %s' "$reached_type"
    printf '\n'

    window_count="$(jq --argjson i "$limit_index" '.limits[$i].windows | length' "$snapshot_file")"
    for ((window_index = 0; window_index < window_count; window_index++)); do
        IFS=$'\x1f' read -r label left_percent resets_at reset_in wait_seconds status < <(
            jq -r --argjson i "$limit_index" --argjson w "$window_index" '
                .limits[$i].windows[$w]
                | [
                    .label,
                    .left_percent,
                    .resets_at,
                    .reset_in_seconds,
                    .wait_seconds,
                    .status
                ]
                | join("\u001f")
            ' "$snapshot_file"
        )

        if [[ "$status" == buffering ]]; then
            printf '%-4s buffer | reset reached | wait %ss\n' \
                "$label" "$wait_seconds"
            continue
        fi

        if [[ "$status" == stale ]]; then
            printf '%-4s stale | reset passed %s ago | wait 0s\n' \
                "$label" "$(format_duration "$reset_in")"
            continue
        fi

        reset_display="$(date -d "@$resets_at" '+%m-%d %H:%M' 2>/dev/null || printf '?')"
        printf '%-4s %s%% left | reset %s (%s) | wait %ss\n' \
            "$label" "$(format_percent "$left_percent")" "$reset_display" \
            "$(format_duration "$reset_in")" "$wait_seconds"
    done
done
