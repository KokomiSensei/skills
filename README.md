# Personal Skills


## 维护方式

每个技能放在 `skills/<skill-name>/`，包含 `SKILL.md` 和所需的辅助。Skills 参考布局：


```
This Repo
└── skills/
    └── new-skill/
        ├── SKILL.md
        ├── agents/openai.yaml
        └── scripts/helper-scripts.sh
```

## Skills 安装

> 指向远端仓库即可，不必专门指向内部的 skills/

从Github安装：

```
npx skills@latest add KokomiSensei/skills -g
```

从本地clone安装：

```
npx skills@latest add <path to this repo> -g
```

也可以使用 `--skill <skill name>` 指定单个技能安装。skill name是 SKILL.md 顶部 YAML 中的 name，不是文件夹名

## 个人工作流补丁

`patch-matt-pocock-workflow`：显式调用后，为当前仓库合并 Matt Pocock 工作流的个人偏好，包括中文写作、UI 与测试、共享依赖、交付和复盘约定。先完成原版 setup；保留项目配置与已有定制。

```bash
npx skills@latest add KokomiSensei/skills -g --skill patch-matt-pocock-workflow
```

安装后在目标仓库显式调用 `$patch-matt-pocock-workflow`。
