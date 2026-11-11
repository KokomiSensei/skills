---
name: patch-matt-pocock-workflow
description: 为当前仓库的 Matt Pocock 工作流应用个人偏好补丁，保留已有配置与定制。
---

# 应用个人工作流补丁

仅在用户显式调用时执行。将本技能附带的资源合并到当前仓库；全局安装只使本技能可用，不修改已安装的上游技能。默认应用全部补丁，用户本次明确排除的部分除外。

## 1. 检查目标

确定目标仓库或 worktree 根目录。读取适用的 agent 指令，检查根目录 `AGENTS.md`、`CLAUDE.md`（包括软链接目标）、`docs/agents/` 和 Git 本地排除配置。

查找并阅读已安装的 setup-matt-pocock-skills/SKILL.md。若无法定位，请用户提供安装位置或附加该技能；确认未安装时，再引导安装。成功阅读其内容后，依据其说明和当前仓库的实际配置，判断是否需要先完成或补齐 setup。需要时说明缺项，引导用户显式调用该技能，完成后继续；保留已有配置与选择。

本技能不升级上游技能或刷新原版模板。保留目标仓库的 tracker、标签、领域布局以及新版模板中的 sub-issue、Wayfinding 等内容；源项目缺少某段内容不构成删除理由。

## 2. 合并补丁

阅读以下资源，然后将内容应用到对应位置。配套文件内容已等价时无需修改；新文件直接复制，已有文件按语义合并。资源是偏好来源，不是覆盖整个目标文件的指令。

| 资源 | 目标 |
| --- | --- |
| [agent-instructions.md](assets/agent-instructions.md) | 根目录 `AGENTS.md` 中的偏好与导航入口 |
| [workflow.md](assets/workflow.md) | `docs/agents/patch/workflow.md` |
| [ui-workflow.md](assets/ui-workflow.md) | `docs/agents/patch/ui-workflow.md` |
| [writing-tests.md](assets/writing-tests.md) | `docs/agents/patch/writing-tests.md` |
| [shared-dependencies.md](assets/shared-dependencies.md) | `docs/agents/patch/shared-dependencies.md` |
| [delivery.md](assets/delivery.md) | `docs/agents/patch/delivery.md` |
| [retro-workflow.md](assets/retro-workflow.md) | `docs/agents/patch/retro-workflow.md` |

已有章节原地更新，保留项目配置和用户定制，避免重复入口。若规则发生行为冲突，展示双方规则和建议，询问后再处理该部分；继续完成无冲突部分。保留既有开发规范入口。

原版配置文件按中文写作偏好维护，保留命令、标识符和语义；GitHub tracker 的多行正文与评论采用临时文件加 `--body-file`，不整体替换 tracker 文件。

检查补丁依赖的技能是否可用，缺少时照常安装文档并报告；实际需要该技能时引导用户安装，不自动安装或虚构其已执行。保留 workflow 资源中的 Plan mode 与用户附加 `to-spec` 流程。

在 Git 的本地 exclude 文件中按需加入 `/.agent-local/`，保留已有规则；使用 `git rev-parse --git-path info/exclude` 定位，不假定 `.git` 是目录。每个 worktree 的 `.agent-local/dependencies.toml` 独立存放在该 worktree 根目录；发现或使用依赖时再创建真实记录，不填入示例或猜测的安装信息。已有被 Git 跟踪的该目录需要向用户说明，不能通过 ignore 假装已取消跟踪。

## 3. 统一 agent 文件入口

以根目录 `AGENTS.md` 为实际内容文件，建立同目录的相对软链接 `CLAUDE.md -> AGENTS.md`。

- 只有普通 `CLAUDE.md`：保留其内容迁移到 `AGENTS.md`，再建立软链接。
- 两个普通文件都存在：先合并独有内容；冲突先询问，确认内容已保留后再将 `CLAUDE.md` 替换为软链接。
- 已有正确软链接：保留。
- 任一文件是其他指向的软链接：展示目标并询问处理方式，避免写穿链接或造成循环。

操作前确认迁移后的内容完整，保留未解决冲突的原文件。目标文件系统无法创建软链接时报告限制，不宣称完成。

## 4. 查找上级指令

补丁安装后，从项目父目录逐层向上查找 `AGENTS.md`，直到文件系统根目录。遵守访问权限，避免重复读取同一软链接目标。上级文件可能是个人全局规则，也可能描述父项目，不能仅凭存在就断定归属。

对每份找到的文件，向用户展示路径、简短内容摘要，以及是否建议引用和原因。询问是否在当前项目的 `AGENTS.md` 中添加 Markdown 链接；得到选择后添加简短且明确适用范围的入口，不修改上级文件，不复制其全文。已有等价链接时说明并保留。优先使用可解析的相对路径，指出该链接依赖当前目录布局；上级文件无法读取时报告，不猜测摘要。

## 5. 验证与交付

检查改动差异、资源入口和本地链接，验证 `CLAUDE.md` 链接目标以及本地排除规则。确保没有带入源项目名称、机器绝对路径、未安装的 lint 规则或虚构的依赖记录。汇报已应用补丁、保留的定制、缺少的技能，以及等待用户决定的冲突或上级链接。无需重新逐项确认无冲突补丁。
