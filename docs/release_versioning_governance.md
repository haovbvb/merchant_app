# 基座发布与版本治理（v1）

## 1. 版本策略

- 基座与公共包采用语义化版本：`MAJOR.MINOR.PATCH`
- `MAJOR`：破坏性变更（需要业务侧改造）
- `MINOR`：向后兼容的能力新增
- `PATCH`：向后兼容的缺陷修复

## 2. 变更记录规范

每次合并到 `main` 的变更需要补齐变更记录，至少包含：

- 影响范围（app_shell / foundation / networking / design_system / feature_xxx）
- 变更类型（breaking / feature / fix / chore）
- 升级动作（是否需要业务侧修改）
- 验证结果（analyze / test / 关键手测项）

## 3. 发布节奏

- 每周固定窗口发 `PATCH/MINOR` 版本
- `MAJOR` 版本需要提前一周发升级公告并提供迁移指南

## 4. 兼容与回滚

- 每次发布前必须通过：
  - `melos run verify:all`
  - 至少 1 个真实业务应用回归
- 发现 P0 问题时：
  - 立即停止扩散
  - 使用最近稳定 tag 回滚
  - 在 24 小时内补充事故复盘

## 5. Tag 与分支

- `main`：可发布主干
- `dev`：日常集成分支
- 发布 tag 规则：`v<major>.<minor>.<patch>`，例如 `v1.2.3`
- 发布分支可选：`release/v<major>.<minor>.<patch>`
