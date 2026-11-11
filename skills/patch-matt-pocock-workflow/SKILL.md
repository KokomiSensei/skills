---
name: patch-matt-pocock-workflow
description: 为当前仓库的 Matt Pocock 工作流应用个人偏好补丁。
---

# 应用个人工作流补丁

将附带资源合并到当前仓库，不修改已安装的上游技能或升级 setup 模板。默认应用全部补丁，用户本次明确排除的部分除外。

## 1. 检查目标

确定目标仓库或 worktree 根目录。读取适用的 agent 指令，检查 README、`AGENTS.md`、`CLAUDE.md` 及其软链接目标、现有文档目录和 Git 本地排除配置。

查找并阅读已安装的 `setup-matt-pocock-skills/SKILL.md`，依据其说明和仓库现状判断是否需要完成或补齐 setup。需要时说明缺项，引导用户显式调用该技能，完成后继续。无法定位技能时，请用户提供位置或附加内容；确认未安装后再引导安装。

## 2. 提议文档组织

阅读 [文档组织 setup](references/document-organization-setup.md)，结合项目现状提出目录分类、文档迁移与入口链接方案。用户审阅同意后落盘；后续补丁路径采用获准的映射。用户暂缓或拒绝时沿用现有结构，继续无冲突补丁。

## 3. 合并补丁

阅读 [assets](assets/) 中的补丁文档，默认按原文件名合并到 `docs/agent/patch/`，以下文件单独处理：

- [agent-instructions.md](assets/agent-instructions.md)：合并到根目录 `AGENTS.md`。
- [issue-tracker-github.md](assets/issue-tracker-github.md)：使用 GitHub tracker 时，合并到 `docs/agent/issue-tracker.md`。
- [document-maintenance.md](assets/document-maintenance.md)：合并到 `docs/maintenance/document-maintenance.md`。

上述目标地址为默认推荐目标地址。若用户在第二步中确定了其他的文件夹组织形式，需要选择对应文件夹放入。如果不确定，与用户确认。

按获准的项目目录方案调整目标及资源内链接。新文件复制资源，已有文件原地合并，保留项目配置与用户定制；等价内容跳过。行为冲突时展示差异和建议，请用户决定，继续处理无冲突部分。

原版配置文件按中文写作偏好维护，保留命令、标识符和语义。

检查补丁依赖的技能，缺少时照常安装文档并报告，实际需要时再引导用户安装。

使用 `git rev-parse --git-path info/exclude` 定位本地排除文件，按需追加 `/.agent-local/`。若该目录已有被 Git 跟踪的文件，报告需要另行处理。

## 4. 统一 agent 文件入口

以根目录 `AGENTS.md` 为实际内容文件，建立同目录的相对软链接 `CLAUDE.md -> AGENTS.md`。

- 只有普通 `CLAUDE.md`：将其内容迁移到 `AGENTS.md`，再建立软链接。
- 两个普通文件都存在：按上述合并规则处理；内容完整合并后，再将 `CLAUDE.md` 替换为软链接。
- 已有正确软链接：保留。
- 任一文件是其他指向的软链接：展示目标并询问处理方式。

## 5. 查找上级指令

补丁安装后，从项目父目录逐层向上查找 `AGENTS.md`，直到文件系统根目录。

对找到的每份文件，展示路径、简短内容摘要，以及是否建议引用和原因，区分个人全局规则与父项目约定。询问用户是否引用；获同意后，在当前项目的 `AGENTS.md` 中添加 Markdown 链接并说明适用范围，优先使用相对路径。

## 6. 配置文档维护

阅读 [文档检查 setup](references/document-check-setup.md)，检查项目现有工具后，让用户选择复用或安装现成工具、项目内实现、跳过检查。按选择完成配置、验收和维护说明；已有明确选择沿用，重复 patch 时保留定制。

## 7. 验证与交付

检查改动差异、文档入口与链接、`CLAUDE.md` 软链接和 Git 本地排除规则。采用文档分类时，核对 README 和 `AGENTS.md` 均链接到文档维护说明，已批准的迁移及入链更新完整。配置检查器时，运行最终检查入口。汇报已应用补丁、文档组织与检查选择及验证结果、缺少的技能和未解决事项。
