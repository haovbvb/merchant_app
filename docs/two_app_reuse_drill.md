# 两类应用复用演练记录

## 1. 目标

验证同一套基础框架可复用到至少两类不同应用形态。

## 2. 应用形态定义

- 认证优先型应用：启动即进入登录流程
- 展示优先型应用：启动即进入功能展示页

## 3. 复用方式

复用同一基座能力：

- AppShellApp
- AppShellFeatureFlags
- feature_auth 路由契约
- design_system 组件与样式

仅通过配置差异形成不同应用形态：

- AuthFirstAppEntryPoint
- ShowcaseFirstAppEntryPoint

## 4. 自动化验证（2026-03-24）

测试文件：test/app_variants_test.dart

- Auth first variant boots to auth login
- Showcase first variant boots to showcase page

结果：两项测试通过。

结论：至少两类不同类型应用已验证可复用同一基座。
