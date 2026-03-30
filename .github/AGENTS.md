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

## AI 任务入口

- 路由/壳层问题：先看 `packages/app_shell`。
- 通用契约/工具问题：先看 `packages/foundation`。
- 网络问题：先看 `packages/networking`。
- UI 规范问题：先看 `packages/design_system`。
- 业务改动：定位到对应 `packages/feature_*`。

## 禁止改动区

- 不跨包引用他包 `src/` 私有实现。
- 不在基座包引入业务包依赖。
- 不在未确认需求时修改公开 contract 语义。

## PR 最小检查项

- 描述影响范围与风险等级。
- 提供回滚方式。
- 提供执行过的验证命令与结果。
