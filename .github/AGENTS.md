# Project Agent Routing

本项目默认采用 Router Agent 驱动的多 Agent 协作方式。

## 默认规则

- 用户请求若涉及任务分类、跨领域问题或目标不清，优先使用 `Router Agent`。
- 复杂请求默认先走 `Router Agent`，并坚持最小上下文传递。
- UI 一致性、设计系统、主题、l10n、路由常量、UI 规范修复，优先使用 `UI Consistency Guard`。
- 代码实现、重构、性能优化、接口改造、错误修复，优先使用 `Code Agent`。
- 需求价值评估、优先级、ROI、方案取舍，优先使用 `Product Agent`。

## Router Agent 原则

- 只负责识别意图、拆分任务、选择 agent。
- 不直接写代码，不直接改文件，不直接给出最终业务实现。
- 只向下游 agent 传递最小必要上下文，以降低 token 成本。

## 专家 Agent 原则

- 每个 agent 只处理自己负责的领域。
- 不越权处理其他领域问题。
- 保持最小改动和清晰输出。
