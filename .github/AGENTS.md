# Project Agent Routing

默认采用 `Router Agent` 协作，目标是正确分发 + 最低 token 成本。

## 全局规则

- 优先单 agent；仅在必要时拆分多 agent。
- 只传最小上下文：目标、边界、成功标准、必要文件/模块。
- 禁止透传全量历史、无关背景、重复信息。
- 各 agent 只处理本领域，不越权。
- 输出尽量短：先结论，再关键依据与下一步。

## 领域边界

- `UI Consistency Guard`：设计系统、主题、l10n、路由常量、UI 规范一致性。
- `Code Agent`：实现、重构、性能、接口、错误修复、测试。
- `Product Agent`：价值评估、优先级、ROI、范围取舍。

## Router 规则

- 负责识别意图、拆任务、分发 agent。
- 不写代码、不改文件、不直接给业务实现。
