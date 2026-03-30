# Workspace 快速开始

本文档用于帮助你在最短时间内跑通模板，并掌握仓库内的高频命令。

## 1. 环境准备

建议先确认：

- Flutter SDK 可用
- Dart 命令可用
- Ruby/Bundler（仅 Fastlane 需要）

## 2. 初始化仓库

仓库根目录执行：

```bash
flutter pub get
```

如果需要统一多包依赖管理：

```bash
dart pub global activate melos
melos bootstrap
```

## 3. 本地运行与验证

```bash
flutter run
flutter analyze
flutter test
```

如需执行全仓命令：

```bash
melos run analyze
melos run test
melos run verify:deps
melos run verify:impact
melos run verify:all
```

## 4. 仓库结构速览

- 根目录：当前模板主工程入口
- packages/：可复用基础包与 feature 包
- docs/：蓝图、清单、演练与治理文档
- tools/：仓库级脚本与自动化工具

## 5. 新功能接入建议

1. 先在 packages/ 新增 feature 包（保持模块边界清晰）
2. 在 app_shell 注册路由与模块开关
3. 用 path 依赖逐步替换主工程旧实现
4. 每阶段执行 analyze + test，确保可回归

如需快速创建新 feature 包：

```bash
dart run tools/scaffold_feature.dart --name feature_order --description "Order feature module"
```

## 6. 文档入口

- docs/foundation_template_checklist.md：建设清单与验收口径
- docs/foundation_template_blueprint.md：目录骨架与契约模板
- docs/foundation_governance_v1.md：治理规范（v1）
- docs/new_app_30min_drill.md：新应用快速启动演练
- docs/config_only_login_example_drill.md：仅改配置验收演练
- docs/base_upgrade_compatibility_drill.md：基座升级兼容演练
- docs/two_app_reuse_drill.md：双应用复用演练
- docs/ai_coding_playbook.md：AI Coding 协作手册
