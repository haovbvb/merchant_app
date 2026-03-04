import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/pack.dart';
import 'package:merchant_app/data/models/swap_bind_info.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/swap_bind_controller.dart';
import 'package:merchant_app/features/work/sales/widgets/swap_battery_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/swap_package_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/swap_payment_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/swap_vehicle_sheet.dart';

class SwapBindPage extends ConsumerStatefulWidget {
  const SwapBindPage({super.key});

  @override
  ConsumerState<SwapBindPage> createState() => _SwapBindPageState();
}

class _SwapBindPageState extends ConsumerState<SwapBindPage> {
  final _userIdController = TextEditingController();
  final _userIdFocusNode = FocusNode();
  String _lastQueriedUserId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(swapBindProvider.notifier).reset();
      _userIdController.clear();
      _lastQueriedUserId = '';
    });
    _userIdFocusNode.addListener(_onUserIdFocusChanged);
  }

  void _onUserIdFocusChanged() {
    if (!_userIdFocusNode.hasFocus) {
      _handleUserIdBlur();
    }
  }

  @override
  void dispose() {
    _userIdFocusNode.removeListener(_onUserIdFocusChanged);
    _userIdFocusNode.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(swapBindProvider);

    // 成功页面
    if (state.submitSuccess) {
      return _SuccessPage(
        documentNo: state.documentNo ?? '',
        paySource: state.paySource,
        onReturn: () {
          ref.read(swapBindProvider.notifier).reset();
          Navigator.of(context).pop();
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    _buildUserIdSection(context),
                    const SizedBox(height: 8),
                    _buildVehicleSection(context),
                    const SizedBox(height: 8),
                    _buildBatterySection(context),
                    const SizedBox(height: 8),
                    _buildPackageSection(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8E8E8), Color(0xFFF5F5F5)],
        ),
      ),
      child: Column(
        children: [
          // 返回按钮
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios, size: 20),
            ),
          ),
          // 绿色电池图标
          Container(
            // width: 72,
            // height: 72,
            decoration: BoxDecoration(
              // color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Image.asset(
                'assets/android/mipmap-xxhdpi/icon_swap_bind.webp',
                // width: 36,
                // height: 36,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.swapBindTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black06Text,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserIdSection(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(swapBindProvider);
    final notifier = ref.read(swapBindProvider.notifier);
    final info = state.info;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.swapBindUserId,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black06Text,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _userIdController,
                  focusNode: _userIdFocusNode,
                  decoration: InputDecoration(
                    hintText: l10n.swapBindUserIdHint,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFCCCCCC),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.black06Text,
                  ),
                  onChanged: (value) {
                    if (value.trim().isEmpty) {
                      _lastQueriedUserId = '';
                      ref.read(swapBindProvider.notifier).reset();
                    }
                  },
                  onSubmitted: (_) => _searchUser(notifier),
                ),
              ),
              GestureDetector(
                onTap: () => _scanUserId(notifier),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: AppIcons.scanIcon(
                    size: 24,
                    color: AppColors.black06Text,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          // 用户信息区域
          if (state.loadingUser)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SizedBox.shrink(),
              ),
            )
          else if (info != null)
            _buildUserInfoCard(info)
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.depositRefundUserEmpty,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(SwapBindInfo info) {
    final fullName = '${info.firstName ?? ''} ${info.lastName ?? ''}'.trim();
    final name = fullName.isNotEmpty
        ? fullName
        : ((info.username ?? '').trim().isNotEmpty ? info.username!.trim() : '-');
    final phone = _formatPhoneWithAreaCode(info.phone);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEEEEEE),
              image: (info.avatar ?? '').isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(info.avatar!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (info.avatar ?? '').isEmpty
                ? const Icon(Icons.person, color: Color(0xFF999999))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phone: $phone',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSection(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(swapBindProvider);
    final notifier = ref.read(swapBindProvider.notifier);
    final vehicles = state.info?.vehicleList ?? [];
    final selected = state.selectedCar;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.swapBindBindVehicle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black06Text,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (selected != null)
            _buildSelectedVehicle(selected, vehicles, notifier)
          else
            GestureDetector(
              onTap: vehicles.isNotEmpty
                  ? () => _selectVehicle(context, vehicles, notifier)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.swapBindSelectVehicle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF999999),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedVehicle(
    CarVo car,
    List<CarVo> vehicles,
    SwapBindNotifier notifier,
  ) {
    return GestureDetector(
      onTap: () => _selectVehicle(context, vehicles, notifier),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // 车辆图片
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                image: (car.img ?? '').isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(car.img!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (car.img ?? '').isEmpty
                  ? const Icon(Icons.directions_bike, color: Color(0xFF999999))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.model} · ${car.spec}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black06Text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SN: ${car.sn ?? '-'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                  if ((car.rentDay ?? 0) > 0) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Remaining Rental days: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          TextSpan(
                            text: '${car.rentDay} days',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatterySection(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(swapBindProvider);
    final notifier = ref.read(swapBindProvider.notifier);
    final batteries = state.info?.batteryList ?? [];
    final selected = state.selectedBattery;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.swapBindBindBattery,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black06Text,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (selected != null)
            _buildSelectedBattery(selected, batteries, notifier)
          else
            GestureDetector(
              onTap: batteries.isNotEmpty
                  ? () => _selectBattery(context, batteries, notifier)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.swapBindSelectBattery,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF999999),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedBattery(
    BatteryVo battery,
    List<BatteryVo> batteries,
    SwapBindNotifier notifier,
  ) {
    return GestureDetector(
      onTap: () => _selectBattery(context, batteries, notifier),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // 电池图片
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                image: (battery.img ?? '').isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(battery.img!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (battery.img ?? '').isEmpty
                  ? const Icon(Icons.battery_full, color: Color(0xFF999999))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${battery.model ?? '-'} · ${battery.spec ?? ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black06Text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SN: ${battery.sn ?? '-'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                  if ((battery.rentDay ?? 0) > 0) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Remaining Rental days: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          TextSpan(
                            text: '${battery.rentDay} days',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageSection(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(swapBindProvider);
    final notifier = ref.read(swapBindProvider.notifier);
    final selected = state.selectedPack;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.swapBindPackage,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black06Text,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (selected != null)
            _buildSelectedPackage(selected, notifier)
          else
            GestureDetector(
              onTap: () => _selectPackage(context, notifier),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.swapBindSelectPackage,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF999999),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedPackage(Pack pack, SwapBindNotifier notifier) {
    final l10n = context.l10n;

    return Column(
      children: [
        // 套餐卡片
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryColor, AppColors.primaryColor],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pack.infoName ?? '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${(pack.packageAmount ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.swapBindAvailableBattery,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pack.batteryType ?? '-'} · ${pack.batteryNum ?? 0} pac',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.swapBindAvailableVehicles,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pack.carType ?? '-',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.swapBindServicePeriod,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fixed period · ${pack.duration ?? 30}days',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.swapBindSwapTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pack.times ?? 0}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Reselect 按钮
        GestureDetector(
          onTap: () => _selectPackage(context, notifier),
          child: Text(
            l10n.swapBindReselect,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2196F3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(swapBindProvider);
    final notifier = ref.read(swapBindProvider.notifier);
    final canSubmit = state.selectedPack != null &&
        state.info != null &&
        !state.submitting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: canSubmit ? () => _showPaymentSheet(notifier) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              disabledBackgroundColor: const Color(0xFFB8D8B8),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: state.submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: SizedBox.shrink(),
                  )
                : Text(
                    l10n.swapBindSubmit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // === 辅助方法 ===

  void _searchUser(SwapBindNotifier notifier) {
    final userId = ScanUtils.getUserCarNum(_userIdController.text.trim());
    if (userId.isNotEmpty) {
      _userIdController.text = userId;
      _lastQueriedUserId = userId;
      notifier.queryUser(userId);
    }
  }

  void _handleUserIdBlur() {
    final notifier = ref.read(swapBindProvider.notifier);
    final userId = ScanUtils.getUserCarNum(_userIdController.text.trim());
    if (userId.isEmpty) {
      _lastQueriedUserId = '';
      notifier.reset();
      return;
    }
    if (userId == _lastQueriedUserId) {
      return;
    }
    _userIdController.text = userId;
    _lastQueriedUserId = userId;
    notifier.queryUser(userId);
  }

  Future<void> _scanUserId(SwapBindNotifier notifier) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (result != null && result.isNotEmpty) {
      final userId = ScanUtils.getUserCarNum(result);
      if (userId.isEmpty) return;
      _userIdController.text = userId;
      _lastQueriedUserId = userId;
      notifier.queryUser(userId);
    }
  }

  Future<void> _selectVehicle(
    BuildContext context,
    List<CarVo> vehicles,
    SwapBindNotifier notifier,
  ) async {
    if (vehicles.isEmpty) return;
    final selected = await SwapVehicleSheet.show(
      context,
      vehicles,
      ref.read(swapBindProvider).selectedCar,
    );
    if (selected != null) {
      notifier.selectCar(selected);
    }
  }

  Future<void> _selectBattery(
    BuildContext context,
    List<BatteryVo> batteries,
    SwapBindNotifier notifier,
  ) async {
    if (batteries.isEmpty) return;
    final selected = await SwapBatterySheet.show(
      context,
      batteries,
      ref.read(swapBindProvider).selectedBattery,
    );
    if (selected != null) {
      notifier.selectBattery(selected);
    }
  }

  Future<void> _selectPackage(
    BuildContext context,
    SwapBindNotifier notifier,
  ) async {
    final state = ref.read(swapBindProvider);

    if (state.selectedCar == null || state.selectedBatteries.isEmpty) {
      final isZh = Localizations.localeOf(context).languageCode
          .toLowerCase()
          .startsWith('zh');
      showToast(
        isZh
            ? '请先选择车辆和电池'
            : 'Please select vehicle and battery first',
      );
      return;
    }

    // 先查询套餐列表
    if (state.packs.isEmpty) {
      await notifier.queryPackList();
    }

    final packs = ref.read(swapBindProvider).packs;
    if (packs.isEmpty) {
      showToast(context.l10n.swapBindPackEmpty);
      return;
    }
    if (!mounted) return;

    final selected = await SwapPackageSheet.show(
      context,
      packs,
      ref.read(swapBindProvider).selectedPack,
    );
    if (selected != null) {
      notifier.selectPack(selected);
    }
  }

  Future<void> _showPaymentSheet(SwapBindNotifier notifier) async {
    final pack = ref.read(swapBindProvider).selectedPack;
    if (pack == null) return;

    final result = await SwapPaymentSheet.show(
      context,
      pack.packageAmount ?? 0,
    );
    if (result == null || !mounted) return;

    // 根据支付方式设置 paySource：Cash=1, Online=2
    final paySource = result['paymentMethod'] == 'Cash' ? 1 : 2;
    notifier.updatePaySource(paySource);

    // 提交
    final l10n = context.l10n;
    final success = await notifier.submit(_userIdController.text.trim());

    if (!mounted) return;
    if (!success) {
      showToast(l10n.swapBindFailed);
    }
  }

  String _formatPhoneWithAreaCode(String? phone) {
    final value = (phone ?? '').trim();
    if (value.isEmpty) return '-';
    final areaCode = (AuthSession.instance.current?.areaCode ?? '').trim();
    if (areaCode.isEmpty || value.startsWith(areaCode)) {
      return value;
    }
    return '$areaCode $value';
  }
}

class _SuccessPage extends StatelessWidget {
  const _SuccessPage({
    required this.documentNo,
    required this.paySource,
    required this.onReturn,
  });

  final String documentNo;
  final int paySource;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: onReturn,
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          l10n.swapBindTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColors.black06Text,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 成功图标
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.swapBindSuccessTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: paySource == 2
                          ? l10n.swapBindSuccessOnlineHint
                          : l10n.swapBindSuccessCashHint,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const TextSpan(
                      text: ' 30 minutes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Document Number
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.swapBindDocumentNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          documentNo.isNotEmpty ? documentNo : '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black06Text,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (documentNo.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: documentNo));
                              showToast(l10n.swapBindCopied);
                            }
                          },
                          child: const Icon(
                            Icons.copy,
                            size: 18,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 返回工作台按钮
              OutlinedButton(
                onPressed: onReturn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  l10n.swapBindReturnWorkbench,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
