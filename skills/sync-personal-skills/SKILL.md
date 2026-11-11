---
name: sync-personal-skills
description: 从 KokomiSensei/skills 远端全局安装缺少的个人技能，并更新已安装的同源技能。
---

# 同步个人技能

将 `KokomiSensei/skills` 远端默认分支中的技能同步到本机全局安装。使用 Skills CLI；本地仓库的未发布修改不作为安装来源。

## 1. 确定同步范围

运行以下只读命令，获取远端技能和本机全局安装列表：

```bash
npx skills@latest add KokomiSensei/skills --list
npx skills@latest list -g
```

使用技能 frontmatter 的 `name`，而非目录名。结合 CLI 的全局安装记录核对来源，将远端技能分为未安装、已安装且同源两组。安装记录通常在 `~/.agents/.skill-lock.json`；设置了 `XDG_STATE_HOME` 时检查其 `skills/.skill-lock.json`。若同名技能来自其他来源或来源无法确定，先向用户说明并确认该项，继续处理已确定的技能。

## 2. 安装与更新

缺少的技能从指定远端全局安装：

```bash
npx skills@latest add KokomiSensei/skills -g --skill <缺少的技能名...> -a <目标 agent...> -y
```

新技能沿用本机已安装个人技能的 agent 目标；没有既有目标时使用当前运行本技能的 agent。用户指定目标时按其选择执行。

已安装且同源的技能按名称更新，保留现有安装目标：

```bash
npx skills@latest update <已安装的同源技能名...> -g -y
```

空组跳过。始终传入具体技能名，避免无名称的 update 更新其他来源。远端已移除的技能保留本地安装。CLI 参数变化时查阅其帮助调整命令。

## 3. 核验结果

重新查看全局安装列表与来源记录，结合命令结果报告新增、已更新、原已最新和失败的技能。失败项说明原因，保留已完成结果。

同步只安装技能，不执行它们。若更新了 `patch-matt-pocock-workflow`，提醒用户需要在目标项目显式调用它，才能更新该项目已应用的补丁。
