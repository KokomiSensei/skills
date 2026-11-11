# 工作流

## grill-me 或 grill-with-docs 技能补丁

当用户使用codex时，如果用户使用了 grill-me 或 grill-with-docs 技能，但未进入plan mode，可能会导致agent无法调用“问问题”工具。在这种情况下：

- 先提醒用户进入plan mode

- 再与用户明确本次plan mode最终给出计划的内容应该是什么（是否使用默认的目标计划产物）：

  在默认工作流中： grill-me / grill-with-docs 环节后，需要衔接to-spec。此时plan mode最终给出的计划内容默认是“spec的写作的计划”（即内容的大纲）：计划尽量精炼，主要是向用户展示双方达成了什么共识，具体的决策细节放在上下文里，进行spec写作的时候参考着上下文和计划写。后续 Implement the Plan，指的是写作 spec，而非直接按照spec修改代码。

- 在用户确认并进入plan mode后，恢复被打断的问问题环节

- 在与用户达成共识后：

  询问用户是否要附加上 to-spec 技能。如果是的话，先不要输出计划，向用户索要 to-spec 技能并暂时结束输出。用户将在下一条消息中附加上该技能，阅读该技能后再决定下一步怎么做。
