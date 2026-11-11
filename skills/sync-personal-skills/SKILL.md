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
npx skills@latest list -g --json
```

按 CLI 返回的技能名称与 `source`，将远端技能分为未安装、已安装且来源为 `KokomiSensei/skills` 两组。同名但来源不同或未知的项目，单独列出请用户决定。

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

重新运行 `list -g --json`，结合命令结果报告新增、已更新、原已最新和失败的技能。失败项说明原因，保留已完成结果。

同步只安装技能，不执行它们。若更新了 `patch-matt-pocock-workflow`，提醒用户需要在目标项目显式调用它，才能更新该项目已应用的补丁。
