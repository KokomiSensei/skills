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