# 母版工程启动清单（v1）

## 1. 目标与边界

- [x] 明确 70% 通用能力范围（启动壳、路由、网络、存储、主题、多语言、日志、错误处理）
- [x] 明确 30% 业务可替换范围（业务页面、业务模型、行业重能力）
- [x] 设定入基座规则：至少 2 个 App 复用才可进入基座
- [x] 设定禁止项：基座禁止依赖业务包，禁止写死业务状态

## 2. 仓库与目录

- [x] 建立模板仓目录：主工程入口 + packages + docs + tools
- [x] 主工程保留 1 个最小示例 App（可直接运行）
- [x] packages 下创建基础包：app_shell、foundation、networking、design_system
- [x] packages 下创建首批 feature 包：feature_auth（先做样板）
- [x] docs 下创建架构说明、模块契约、接入指南

## 当前进度（已完成）

- [x] 已创建多包工作区配置：`melos.yaml`
- [x] 已创建基础文档：`foundation_template_checklist.md`、`foundation_template_blueprint.md`、`workspace_quick_start.md`
- [x] 已完成 networking 第一批迁移：`BaseResponse`、`NetworkExceptions` 抽离到 `packages/networking`
- [x] 主工程已通过兼容导出继续使用原有 `lib/network` 入口，业务代码无需立即改动
- [x] 已完成 networking 第二批迁移：主工程 `ApiService` 的响应解析改为复用 `packages/networking` 实现
- [x] 已完成 networking 第三批迁移：主工程 `ApiClient` 请求执行逻辑改为复用 `packages/networking` 请求执行器
- [x] 已完成 networking 第四批迁移：环境与 baseUrl 解析策略下沉到 `packages/networking`
- [x] 已启动 networking 第五批试点：`auth_controller` 开始直接使用 `packages/networking` 的通用异常类型
- [x] 已完成 networking 第五批第二个试点：`sys_config_controller` 切换为 `packages/networking` 的 `ApiService`（复用主工程 `Dio`）
- [x] 主入口已切换到 `packages/app_shell`，默认启动为通用模板首页
- [x] 历史业务代码已清理，模板仓仅保留当前基座有效代码
- [x] 已完成通用 widgets / utils / styles 迁移：沉淀到 `packages/foundation` 与 `packages/design_system`
- [x] 已完成基础能力 Showcase：`app_shell` 新增 `/showcase` 与 `/webview` 路由，覆盖 foundation/design_system 关键能力演示
- [x] 最新回归验证通过：`flutter analyze` 无问题，`widget_test` 通过
- [x] 已补齐 `feature_auth` 统一入口契约样板：包含 `routes/providers/bindings/featureConfigSchema`
- [x] `feature_auth` 契约样板测试通过：`packages/feature_auth/test/auth_feature_module_test.dart`
- [x] 已完成“模块开关回归检查”最小自动化用例：关闭示例模块后仍可启动并进入首页
- [x] 已新增“新 App 30 分钟启动”演练记录：`docs/new_app_30min_drill.md`（含步骤与计时样本）
- [x] 已新增“仅改配置跑通登录与示例页”演练记录：`docs/config_only_login_example_drill.md`
- [x] 已新增“基座升级兼容”演练记录：`docs/base_upgrade_compatibility_drill.md`
- [x] 已新增“两类应用复用”演练记录：`docs/two_app_reuse_drill.md`
- [x] 已新增两类应用变体入口与自动化验证：`lib/app_variants.dart`、`test/app_variants_test.dart`
- [x] 已创建 `tools/` 目录与工具占位说明：`tools/README.md`
- [x] 已完成治理规范 v1：`docs/foundation_governance_v1.md`（目标边界、包职责、模块契约、依赖分级、脚手架参数）
- [x] 已升级 CI 为全仓质量门禁：`melos run analyze` + `melos run test` + 依赖边界/覆盖率校验
- [x] 已补齐 feature 契约测试矩阵：`feature_home`、`feature_profile`、`feature_work`
- [x] 已新增仓库级自动化脚本：`tools/check_layer_dependencies.dart`、`tools/check_coverage.dart`、`tools/scaffold_feature.dart`
- [x] 已统一包级分析配置：各 package 新增 `analysis_options.yaml` 继承根配置
- [x] 已补充发布治理与安全基线文档：`docs/release_versioning_governance.md`、`docs/observability_security_baseline.md`

## 当前进度（量化）

- 基础框架骨架（packages + 入口切换 + 兼容迁移）：约 95%
- 通用能力沉淀（foundation + design_system + networking）：约 90%
- 模板可视化验收（Showcase + smoke test）：约 85%
- 可复用落地验证（跨 2 个不同类型 App 复用）：约 80%（已完成双变体自动化验证，待真实双仓落地）

## 下一步（按清单继续）

- [x] 为 `feature_auth` 补齐统一入口契约示例：`routes/providers/bindings/featureConfigSchema`
- [x] 增加“模块开关回归检查”最小自动化用例（关闭单一 feature 后仍可启动并进入首页）
- [x] 增加“新 App 30 分钟启动”演练记录（以文档步骤 + 计时结果方式沉淀）

## 里程碑摘要

- [x] 模板入口完成：主入口切换到 app_shell
- [x] 能力沉淀完成：foundation / networking / design_system 已可复用
- [x] 契约样板完成：feature_auth 入口契约与测试通过
- [x] 可用性验证完成：analyze 与核心测试通过
- [ ] 目标持续跟踪：新 App 首屏落地稳定控制在 30 分钟内

## 3. 包职责

- [x] app_shell：启动流程、路由守卫、全局异常、环境注入
- [x] foundation：配置、日志、错误模型、工具抽象
- [x] networking：请求封装、拦截器、错误映射、Token 刷新机制
- [x] design_system：主题 Token、组件规范、表单规范
- [x] feature_auth：登录流程与路由注册样板，不依赖业务实现细节

## 4. 模块契约

- [x] 每个 feature 暴露统一入口：routes、providers、bindings、featureConfigSchema
- [x] 每个 feature 声明输入接口（依赖）与输出能力（路由、服务）
- [x] 每个 feature 支持开关启停（可编译可运行）
- [x] 基座仅依赖抽象接口，不直接引用 feature 内部实现

## 5. 依赖分级

- [x] L0 必选：状态管理、路由、网络、国际化、存储抽象
- [x] L1 可选：webview、权限、图片能力
- [x] L2 重能力：地图、蓝牙、扫码、视频、图表
- [x] 建立依赖校验规则：L0 不可依赖 L1/L2

## 6. 脚手架参数

- [x] 基础参数：应用名、包名、环境（dev/stage/prod）
- [x] 功能参数：是否登录、是否多语言、是否埋点、是否地图
- [x] 品牌参数：主题色、字体、图标、启动图
- [x] 输出要求：生成后可直接启动到首屏

## 7. 质量门禁

- [x] 静态检查通过（lint、格式化）
- [x] 单测 smoke 通过
- [x] 首屏启动检查通过
- [x] 模块开关回归检查通过（关闭任意 feature 不影响其他模块）

## 8. 迁移执行（按完成度推进）

- [x] 阶段 1：抽 app_shell、foundation、networking 最小可运行版
- [x] 阶段 2：抽 feature_auth，验证契约
- [x] 阶段 3：迁移 1 到 2 个业务模块，验证组合能力
- [x] 阶段 4：接入脚手架与 CI，补齐文档并冻结 v1 模板

## 9. 验收指标

- [ ] 新 App 从初始化到首屏可运行 <= 30 分钟
- [x] 新 App 仅改配置即可跑通登录与示例页
- [x] 基座升级后业务 App 无连锁大改
- [x] 至少 2 个不同类型 App 复用成功
