# 母版工程目录骨架与接口模板（v1）

## 1. 目标

- 以 monorepo 组织通用能力和业务插件
- 保证新项目可一键初始化并最小可运行
- 保持 70% 通用能力沉淀 + 30% 业务灵活替换

## 2. 推荐目录骨架

```text
.
├── apps/
│   ├── merchant_app/
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── app_bootstrap.dart
│   │   │   ├── app_config.dart
│   │   │   └── feature_registry.dart
│   │   ├── pubspec.yaml
│   │   └── test/
│   └── demo_app/
│       ├── lib/
│       └── pubspec.yaml
├── packages/
│   ├── app_shell/
│   │   ├── lib/
│   │   │   ├── app_shell.dart
│   │   │   ├── src/bootstrap/
│   │   │   ├── src/router/
│   │   │   └── src/error/
│   │   └── pubspec.yaml
│   ├── foundation/
│   │   ├── lib/
│   │   │   ├── foundation.dart
│   │   │   ├── src/config/
│   │   │   ├── src/log/
│   │   │   ├── src/storage/
│   │   │   └── src/contracts/
│   │   └── pubspec.yaml
│   ├── networking/
│   │   ├── lib/
│   │   │   ├── networking.dart
│   │   │   ├── src/client/
│   │   │   ├── src/interceptors/
│   │   │   └── src/models/
│   │   └── pubspec.yaml
│   ├── design_system/
│   │   ├── lib/
│   │   │   ├── design_system.dart
│   │   │   ├── src/theme/
│   │   │   ├── src/tokens/
│   │   │   └── src/widgets/
│   │   └── pubspec.yaml
│   └── feature_auth/
│       ├── lib/
│       │   ├── feature_auth.dart
│       │   ├── src/routes/
│       │   ├── src/providers/
│       │   └── src/ui/
│       └── pubspec.yaml
├── tools/
│   ├── bootstrap/
│   │   ├── bin/bootstrap.dart
│   │   └── lib/src/options.dart
│   └── scripts/
│       ├── verify_layers.sh
│       └── verify_template.sh
└── docs/
    ├── foundation_template_checklist.md
    ├── foundation_template_blueprint.md
    ├── architecture_decision_record.md
    ├── module_contract.md
    └── quick_start.md
```

## 3. 包职责与依赖边界

- app_shell
  - 职责：应用启动流程、路由守卫、全局异常处理、生命周期桥接
  - 依赖：foundation、design_system（可选）、go_router
- foundation
  - 职责：配置、日志、存储抽象、通用契约
  - 依赖：尽量纯 Dart，避免 Flutter UI 依赖
- networking
  - 职责：Dio 客户端、拦截器、错误映射、Token 刷新策略
  - 依赖：foundation、dio
- design_system
  - 职责：主题 Token、通用组件、样式规范
  - 依赖：foundation、flutter
- feature_auth
  - 职责：认证业务最小样板（登录页、认证状态、路由）
  - 依赖：foundation、app_shell、networking（仅通过抽象）

依赖规则：

- L0（foundation）不能依赖 L1/L2 功能包
- 业务 feature 不可互相强依赖，通过契约解耦
- 基座包禁止引用业务 DTO 或业务常量

## 4. 最小契约模板

### 4.1 Feature 模块统一入口

```dart
abstract interface class AppFeatureModule {
  String get key;

  /// 向主路由注册子路由
  List<RouteBase> routes();

  /// 暴露本模块的 Provider 列表（可选）
  List<Override> providerOverrides();

  /// 模块初始化（可做轻量注册）
  Future<void> init();

  /// 模块销毁（释放资源）
  Future<void> dispose();
}
```

### 4.2 配置契约

```dart
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.baseUrl,
    required this.env,
    required this.locale,
    required this.features,
  });

  final String appName;
  final String baseUrl;
  final String env; // dev/stage/prod
  final String locale; // zh_CN/en_US
  final Map<String, bool> features; // feature 开关
}
```

### 4.3 日志契约

```dart
abstract interface class AppLogger {
  void d(String message, {Map<String, Object?>? extra});
  void i(String message, {Map<String, Object?>? extra});
  void w(String message, {Map<String, Object?>? extra});
  void e(String message, {Object? error, StackTrace? stackTrace});
}
```

### 4.4 存储契约

```dart
abstract interface class KeyValueStore {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> remove(String key);
  Future<void> clear();
}
```

### 4.5 认证仓储契约（示例）

```dart
class AuthSession {
  const AuthSession({required this.accessToken, required this.userId});

  final String accessToken;
  final String userId;
}

abstract interface class AuthRepository {
  Future<AuthSession> signIn({required String username, required String password});
  Future<void> signOut();
  Future<AuthSession?> restore();
}
```

## 5. 路由装配模板

```dart
class FeatureRegistry {
  const FeatureRegistry(this.features);

  final List<AppFeatureModule> features;

  List<RouteBase> collectRoutes() {
    return [
      for (final module in features) ...module.routes(),
    ];
  }
}
```

```dart
GoRouter buildRouter(FeatureRegistry registry) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      ...registry.collectRoutes(),
    ],
  );
}
```

## 6. 新 App 脚手架参数清单

- 基础参数
  - appName
  - packageName
  - orgName
  - env（dev/stage/prod）
- 功能参数
  - withAuth
  - withI18n
  - withAnalytics
  - withCrashReport
  - withMap
  - withScanner
- 视觉参数
  - brandPrimaryColor
  - brandFontFamily
  - appIconSet
  - splashAsset

示例：

```bash
dart run tools/bootstrap/bin/bootstrap.dart \
  --appName demo_app \
  --packageName com.example.demo \
  --env dev \
  --withAuth true \
  --withI18n true \
  --withAnalytics false \
  --withMap false
```

## 7. 迁移执行模板

- 第 1 批：app_shell + foundation + networking
- 第 2 批：feature_auth（样板插件）
- 第 3 批：feature_home / feature_profile（验证组合）
- 第 4 批：脚手架 + CI + 文档冻结

## 8. 质量门禁模板

- `flutter analyze` 通过
- `flutter test` smoke 通过
- 模板项目首屏启动通过
- 关闭任意 feature 仍可编译
- 依赖越界检查通过（verify_layers.sh）

## 9. 快速实施建议

- 先在当前仓库内按目录创建 `packages/` 雏形，不立即全量迁移
- 先把网络层和配置层抽离，避免第一步就碰业务页面
- 每迁移一个包，必须补 1 个最小示例与 1 个 smoke test
