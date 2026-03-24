# 仅改配置跑通登录与示例页演练记录

## 1. 目标

验证在不改业务代码的前提下，仅通过 AppShell 配置即可进入：

- 登录页（feature_auth）
- 示例页（example）

## 2. 配置入口

配置对象：AppShellFeatureFlags

关键参数：

- enableAuthFeature
- enableExampleFeature
- initialLocation

## 3. 验证方式

通过 Widget Test 执行两组配置启动验证：

- 登录页配置
  - enableAuthFeature: true
  - initialLocation: /auth/login
- 示例页配置
  - enableExampleFeature: true
  - initialLocation: /example

## 4. 自动化结果（2026-03-24）

测试文件：test/widget_test.dart

通过断言：

- 登录页场景出现 Auth Login 与 feature_auth contract sample page
- 示例页场景出现 Example Feature 与 返回模板首页

结论：验收指标“仅改配置即可跑通登录与示例页”达成。
