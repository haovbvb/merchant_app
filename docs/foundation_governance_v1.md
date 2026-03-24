# 基础框架治理规范（v1）

## 1. 目标与边界

### 1.1 70% 通用能力范围（纳入基座）

- 启动壳：应用入口、生命周期初始化、全局导航
- 路由：路由注册、路由守卫、默认首页与变体首页
- 网络：请求封装、错误映射、环境与 baseUrl 解析
- 存储：键值存储抽象、会话状态持久化
- 主题：颜色、字体、间距、阴影与组件样式规范
- 多语言：本地化能力、日期与文案格式化
- 日志：统一日志接口与分级打印
- 错误处理：统一异常模型、通用错误提示策略

### 1.2 30% 业务可替换范围（保留在业务层）

- 业务页面与业务流程编排
- 行业专属模型、字段与规则
- 行业重能力（特殊设备协议、行业报表、专有引擎）
- 与单一业务强绑定的 DTO、常量与文案

### 1.3 入基座规则

- 任一能力必须在至少 2 个不同类型 App 中复用验证后，方可纳入基座。
- 未达到复用阈值的能力，先保留在 feature 包或应用层。

### 1.4 禁止项

- 基座禁止依赖业务包。
- 基座禁止写死业务状态与业务常量。
- 基座禁止直接引用业务 DTO。

## 2. 包职责（v1）

- app_shell：启动流程、路由守卫、全局异常、环境注入与功能开关
- foundation：配置模型、日志抽象、错误模型、工具抽象、通用契约
- networking：请求封装、拦截器、错误映射、Token 刷新机制
- design_system：主题 Token、组件规范、表单规范与通用 UI 组件
- feature_auth：登录流程与路由注册样板，不依赖业务实现细节

## 3. 模块契约（v1）

每个 feature 模块必须暴露以下统一入口：

- routes：模块路由
- providers：模块依赖注入标识或 Provider 映射
- bindings：模块绑定项（存储、API、能力注入）
- featureConfigSchema：模块配置 Schema（含默认值与说明）

每个 feature 必须声明：

- 输入接口：依赖项（存储、网络、系统能力）
- 输出能力：路由、服务、状态提供器

模块开关要求：

- 支持开关启停
- 关闭模块后其路由不注册，且不影响其他模块启动

基座依赖约束：

- 基座只依赖抽象接口，不直接引用 feature 内部实现

## 4. 依赖分级（v1）

- L0 必选：状态管理、路由、网络、国际化、存储抽象
- L1 可选：webview、权限、图片能力
- L2 重能力：地图、蓝牙、扫码、视频、图表

依赖规则：

- L0 不可依赖 L1/L2
- L1 不可依赖 L2
- feature 包可按需依赖 L1/L2，但必须通过契约边界隔离

## 5. 脚手架参数（v1）

### 5.1 基础参数

- appName
- packageName
- env（dev/stage/prod）

### 5.2 功能参数

- withAuth
- withI18n
- withAnalytics
- withMap

### 5.3 品牌参数

- brandPrimaryColor
- brandFontFamily
- appIcon
- splashAsset

### 5.4 输出要求

- 生成后可直接启动到首屏
- 默认包含至少 1 个可运行 feature 示例
- 默认包含 smoke test 与 analyze 可通过配置

## 6. 对应实现映射（当前仓库）

- 统一路由与开关：packages/app_shell
- 统一契约与工具：packages/foundation
- 网络能力下沉：packages/networking
- 主题与组件：packages/design_system
- 认证模块样板：packages/feature_auth
- 最小示例应用：主工程入口（lib/main.dart）
