## 偏好语言

编写或更新文档、代码注释、issue、PR、commit message 时优先使用中文。ADR、GLOSSARY、Triage Labels、Spec、Tickets 等专有术语、GLOSSARY 中定义的术语，以及命令、路径和标识符保留英文。

GLOSSARY 术语标题采用 `**中文 | English**`，描述和 Avoid 使用中文。

## Agent skills

保留本仓库已有的 issue tracker、triage labels、领域文档和开发规范入口；读取或更新任务前阅读 issue tracker 配置，进行 triage 前阅读标签配置，探索仓库前阅读领域文档配置。

### 人机协作

与用户交互时，先阅读 [人机协作流程](docs/agent/patch/workflow.md)。

### UI/UX

设计、实现、修改或审查 UI/UX 前，先阅读 [UI/UX 工作流程](docs/agent/patch/ui-workflow.md)。

### 浏览器测试

编写、运行或审查浏览器测试前，先阅读 [浏览器测试规范](docs/agent/patch/writing-tests.md)。

### 共享依赖

需要下载或使用可跨项目或在项目内复用的软件、SDK、工具链或模型等具有明显存储和下载开销的产物前，先阅读 [共享依赖规范](docs/agent/patch/shared-dependencies.md)。

### 提交与交付

规划提交、推送、创建或更新 PR，以及执行已授权部署前，先阅读 [交付规范](docs/agent/patch/delivery.md)。

### 复盘与暂存改进

用户调用 `retro`、要求先记下来以后处理，或明确暂缓已同意的改进时，先阅读 [复盘与暂存流程](docs/agent/patch/retro-workflow.md)。普通任务不读取 `docs/retro/`；显式复盘可读取本次范围内相关记录，单纯暂存仅访问需要创建或更新的记录。

### 文档维护

新增、或维护现有文档前，先阅读 [文档维护说明](docs/maintenance/document-maintenance.md)。
