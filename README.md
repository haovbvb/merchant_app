# Universal Flutter App Template

通用型 Flutter 基础框架模板，提供可运行的 App Shell、基础包分层与最小示例路由，可作为新业务 App 的统一起点。

## 你会得到什么

- 可直接启动的模板入口（主工程）
- 可复用基础包（foundation/networking/design_system/app_shell）
- 认证模块契约样板（feature_auth）
- 配套演练与治理文档（docs/）

## 当前状态

- 主入口已切换到 App Shell（lib/main.dart）
- 历史业务代码已清理，仅保留模板有效基座
- 主工程依赖已收敛到模板最小集合

## 项目结构（核心）

- lib/main.dart：模板应用入口
- packages/app_shell：应用壳与路由装配
- packages/foundation：基础契约、通用能力
- packages/networking：通用网络请求能力
- packages/design_system：主题与组件骨架
- packages/feature_auth：认证模块契约样板
- docs/：清单、蓝图、演练与治理规范

## 快速开始

1. 安装依赖

```bash
flutter pub get
```

2. 启动模板

```bash
flutter run
```

3. 运行检查

```bash
flutter analyze
flutter test
```

## 文档导航

- docs/workspace_quick_start.md：工作区快速上手
- docs/foundation_template_checklist.md：模板建设清单与验收状态
- docs/foundation_template_blueprint.md：目录骨架与契约蓝图
- docs/foundation_governance_v1.md：治理规范（v1）

## Fastlane（根目录）

- 配置目录：fastlane/
- Ruby 依赖：Gemfile（仓库根目录）

常用命令（仓库根目录执行）：

```bash
bundle install
bundle exec fastlane ios pgyer
bundle exec fastlane ios pgyer_all
```

## 扩展到新业务的建议路径

1. 在 packages/ 新建业务 feature 包（如 feature_order、feature_map）
2. 在 app_shell 注册模块路由与开关
3. 在主工程完成应用装配（配置、品牌、环境）
4. 按 docs/foundation_template_checklist.md 阶段推进并验收
