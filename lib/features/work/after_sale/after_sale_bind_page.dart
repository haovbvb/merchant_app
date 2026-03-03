import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/data/models/after_sale_can_bind_order_bean.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/after_sale/after_sale_bind_controller.dart';
import 'package:merchant_app/features/work/after_sale/after_sale_bind_success_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class AfterSaleBindPage extends ConsumerStatefulWidget {
  const AfterSaleBindPage({super.key});

  @override
  ConsumerState<AfterSaleBindPage> createState() => _AfterSaleBindPageState();
}

class _AfterSaleBindPageState extends ConsumerState<AfterSaleBindPage> {
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _deviceController = TextEditingController();
  final FocusNode _cardFocusNode = FocusNode();
  final FocusNode _deviceFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _cardFocusNode.addListener(() {
      if (!_cardFocusNode.hasFocus) {
        _fetchUserDetailWithFeedback();
      }
    });
    _deviceFocusNode.addListener(() {
      if (!_deviceFocusNode.hasFocus) {
        _fetchDeviceInfoWithFeedback();
      }
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _deviceController.dispose();
    _cardFocusNode.dispose();
    _deviceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(afterSaleBindProvider);
    final notifier = ref.read(afterSaleBindProvider.notifier);
    final l10n = context.l10n;
    _syncControllers(state);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (state.loading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: ClipRRect(
                              child: Image.asset(
                                'assets/android/mipmap-xxhdpi/icon_aftersale_binding.webp',
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.afterSaleBindTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // User ID section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            label: l10n.afterSaleBindCardNumLabel,
                            hint: l10n.afterSaleBindCardNumHint,
                            controller: _cardController,
                            focusNode: _cardFocusNode,
                            onChanged: notifier.updateCardNum,
                            onSubmitted: (_) => _fetchUserDetailWithFeedback(),
                            onScan: _scanCardNum,
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          // User info card
                          if (state.userDetail != null)
                            _UserInfoCard(
                              avatar: state.userDetail?.avatar,
                              cardNum: state.userDetail?.cardNum ?? '-',
                              name: _getUserName(state),
                              phone: _getUserPhone(state),
                            )
                          else
                            _EmptyInfoCard(
                              text: l10n.afterSaleBindUserInfoEmpty,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // After-sales Order section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _OrderSelector(
                            title: l10n.afterSaleBindSelectableOrders,
                            hint: l10n.afterSaleBindNoOrders,
                            orders: state.orders,
                            selectedOrder: state.selectedOrder,
                            onTap: () =>
                                _showOrderSelector(context, state, notifier),
                            onReselect: () =>
                                _showOrderSelector(context, state, notifier),
                            l10n: l10n,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Device SN section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            label: l10n.afterSaleBindDeviceSnLabel,
                            hint: l10n.afterSaleBindDeviceSnHint,
                            controller: _deviceController,
                            focusNode: _deviceFocusNode,
                            onChanged: notifier.updateDeviceSn,
                            onSubmitted: (_) => _fetchDeviceInfoWithFeedback(),
                            onScan: _scanDeviceSn,
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          // Device info card
                          if (state.deviceInfo != null)
                            _DeviceInfoCard(
                              deviceInfo: state.deviceInfo!,
                              l10n: l10n,
                            )
                          else
                            _EmptyInfoCard(
                              text: l10n.afterSaleBindDeviceInfoEmpty,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom button
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF5F5F5),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed:
                      state.binding ||
                          state.cardNum.trim().isEmpty ||
                          state.deviceSn.trim().isEmpty ||
                        state.selectedOrder == null ||
                        state.deviceInfo == null
                      ? null
                      : () => _submit(context, l10n, notifier),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: state.binding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          l10n.afterSaleBindConfirm,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onScan,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                ),
              ),
              if (onScan != null)
                GestureDetector(
                  onTap: onScan,
                  child: AppIcons.scanIcon(size: 24, color: Colors.black54),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUserName(AfterSaleBindState state) {
    final detail = state.userDetail;
    if (detail == null) return '-';
    if (detail.username?.isNotEmpty == true) {
      return detail.username!;
    }
    final name = [detail.firstName, detail.lastName]
        .where((e) => e?.isNotEmpty == true)
        .toList();
    return name.isEmpty ? '-' : name.join(' ');
  }

  String _getUserPhone(AfterSaleBindState state) {
    final detail = state.userDetail;
    if (detail == null || (detail.phone?.isEmpty ?? true)) return '-';
    final areaCode = AuthSession.instance.current?.areaCode ?? '';
    if (areaCode.isEmpty) return detail.phone ?? '-';
    return '$areaCode${detail.phone ?? ''}';
  }

  Future<void> _scanCardNum() async {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const QrScanPage(allowManualInput: true)));
    if (!mounted || result == null || result.isEmpty) return;
    final cardNum = ScanUtils.getUserCarNum(result);
    if (cardNum.isEmpty) return;
    _cardController.text = cardNum;
    ref.read(afterSaleBindProvider.notifier).updateCardNum(cardNum);
    await _fetchUserDetailWithFeedback();
  }

  Future<void> _scanDeviceSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage(allowManualInput: true, parseDeviceSn: true)),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _deviceController.text = result;
    ref.read(afterSaleBindProvider.notifier).updateDeviceSn(result);
    await _fetchDeviceInfoWithFeedback();
  }

  Future<void> _fetchUserDetailWithFeedback() async {
    final notifier = ref.read(afterSaleBindProvider.notifier);
    final success = await notifier.fetchUserDetail();
    if (!mounted || success) return;
    final message = ref.read(afterSaleBindProvider).errorMessage;
    if (message != null && message.isNotEmpty) {
      showToast(message);
    }
  }

  Future<void> _fetchDeviceInfoWithFeedback() async {
    final notifier = ref.read(afterSaleBindProvider.notifier);
    final success = await notifier.fetchDeviceInfo();
    if (!mounted || success) return;
    final message = ref.read(afterSaleBindProvider).errorMessage;
    if (message != null && message.isNotEmpty) {
      showToast(message);
    }
  }

  void _syncControllers(AfterSaleBindState state) {
    if (_cardController.text != state.cardNum) {
      _cardController.text = state.cardNum;
    }
    if (_deviceController.text != state.deviceSn) {
      _deviceController.text = state.deviceSn;
    }
  }

  void _showOrderSelector(
    BuildContext context,
    AfterSaleBindState state,
    AfterSaleBindNotifier notifier,
  ) {
    if (state.orders.isEmpty) {
      showToast(context.l10n.afterSaleBindNoOrders);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderSelectorSheet(
        orders: state.orders,
        selectedOrder: state.selectedOrder,
        onSelected: (order) {
          notifier.selectOrder(order);
          _deviceController.clear();
          Navigator.of(context).pop();
        },
        l10n: context.l10n,
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    AppLocalizations l10n,
    AfterSaleBindNotifier notifier,
  ) async {
    final success = await notifier.bindOrder();
    if (!context.mounted) return;

    if (!success) {
      final state = ref.read(afterSaleBindProvider);
      if (state.errorMessage != null) {
        await ConfirmDialog.alert(
          context: context,
          message: state.errorMessage ?? l10n.afterSaleBindDeviceMismatch,
          buttonText: l10n.afterSaleBindOk,
        );
      }
      return;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AfterSaleBindSuccessPage()));
    if (!context.mounted) return;
    ref.read(afterSaleBindProvider.notifier).reset();
    _cardController.clear();
    _deviceController.clear();
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({
    required this.avatar,
    required this.cardNum,
    required this.name,
    required this.phone,
  });

  final String? avatar;
  final String cardNum;
  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: avatar != null && avatar!.isNotEmpty
                  ? NetworkImage(avatar!)
                  : null,
              child: avatar == null || avatar!.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: context.l10n.afterSaleBindUserIdLabel,
                  value: cardNum,
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  label: context.l10n.afterSaleBindUserNameLabel,
                  value: name,
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  label: context.l10n.afterSaleBindUserPhoneLabel,
                  value: phone,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyInfoCard extends StatelessWidget {
  const _EmptyInfoCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _OrderSelector extends StatelessWidget {
  const _OrderSelector({
    required this.title,
    required this.hint,
    required this.orders,
    required this.selectedOrder,
    required this.onTap,
    required this.onReselect,
    required this.l10n,
  });

  final String title;
  final String hint;
  final List<AfterSaleCanBindOrderBean> orders;
  final AfterSaleCanBindOrderBean? selectedOrder;
  final VoidCallback onTap;
  final VoidCallback onReselect;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (selectedOrder == null) {
      // Empty state - show dropdown hint
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hint,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Selected state - show order details
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: onReselect,
                child: Text(
                  l10n.afterSaleBindReselect,
                  style: TextStyle(fontSize: 14, color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 20,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                selectedOrder!.orderNo ?? '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_orderTypeLabel(selectedOrder!.type)} | ${_orderStatusLabel(selectedOrder!.status)}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.afterSaleBindApplicableDevices,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                _getApplicableDevices(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _orderTypeLabel(int? type) {
    if (type == 1) return l10n.afterSaleBindOrderTypeSale;
    if (type == 2) return l10n.afterSaleBindOrderTypeLease;
    return '-';
  }

  String _orderStatusLabel(int? status) {
    if (status == 1) return l10n.afterSaleBindOrderStatusPaid;
    if (status == 2) return l10n.afterSaleBindOrderStatusInstallment;
    if (status == 3) return l10n.afterSaleBindOrderStatusLease;
    return '-';
  }

  String _getApplicableDevices() {
    if (selectedOrder == null) return '-';
    if (selectedOrder!.deviceType == 1) {
      return '${l10n.afterSaleBindBatteryLabel} | ${selectedOrder!.batteryType ?? '-'}';
    }
    return '${l10n.afterSaleBindVehicleLabel} | ${selectedOrder!.carType ?? '-'}';
  }
}

class _OrderSelectorSheet extends StatelessWidget {
  const _OrderSelectorSheet({
    required this.orders,
    required this.selectedOrder,
    required this.onSelected,
    required this.l10n,
  });

  final List<AfterSaleCanBindOrderBean> orders;
  final AfterSaleCanBindOrderBean? selectedOrder;
  final ValueChanged<AfterSaleCanBindOrderBean> onSelected;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.afterSaleBindSelectOrder,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final isSelected = selectedOrder?.orderNo == order.orderNo;
                  return _OrderCard(
                    order: order,
                    isSelected: isSelected,
                    onTap: () => onSelected(order),
                    l10n: l10n,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    l10n.afterSaleBindCancel,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isSelected,
    required this.onTap,
    required this.l10n,
  });

  final AfterSaleCanBindOrderBean order;
  final bool isSelected;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primaryColor, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.afterSaleBindOrderNo}: ${order.orderNo ?? '-'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              l10n.afterSaleBindOrderType,
              _orderTypeLabel(order.type),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              l10n.afterSaleBindOrderStatus,
              _orderStatusLabel(order.status),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              l10n.afterSaleBindApplicableDevices,
              _getApplicableDevices(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }

  String _orderTypeLabel(int? type) {
    if (type == 1) return l10n.afterSaleBindOrderTypeSale;
    if (type == 2) return l10n.afterSaleBindOrderTypeLease;
    return '-';
  }

  String _orderStatusLabel(int? status) {
    if (status == 1) return l10n.afterSaleBindOrderStatusPaid;
    if (status == 2) return l10n.afterSaleBindOrderStatusInstallment;
    if (status == 3) return l10n.afterSaleBindOrderStatusLease;
    return '-';
  }

  String _getApplicableDevices() {
    if (order.deviceType == 1) {
      return '${l10n.afterSaleBindBatteryLabel} | ${order.batteryType ?? '-'}';
    }
    return '${l10n.afterSaleBindVehicleLabel} | ${order.carType ?? '-'}';
  }
}

class _DeviceInfoCard extends StatelessWidget {
  const _DeviceInfoCard({required this.deviceInfo, required this.l10n});

  final BatterOrVehicleInfo deviceInfo;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isBattery = deviceInfo.deviceType == 1;

    if (isBattery) {
      return _BatteryCard(battery: deviceInfo.batteryVo, l10n: l10n);
    }
    return _VehicleCard(vehicle: deviceInfo.carVo, l10n: l10n);
  }
}

class _BatteryCard extends StatelessWidget {
  const _BatteryCard({required this.battery, required this.l10n});

  final BatteryVo? battery;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: battery?.img != null && battery!.img!.isNotEmpty
                        ? Image.network(battery!.img!, fit: BoxFit.contain)
                        : const Icon(
                            Icons.battery_full,
                            size: 32,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          battery?.sn ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _Tag(
                              text:
                                  '${l10n.afterSaleBindBatteryLabel} · ${battery?.batModel ?? battery?.batteryType ?? '-'}',
                            ),
                            _Tag(text: battery?.batSpec ?? '-'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: l10n.afterSaleBindSoc,
                      value: '${battery?.soc ?? '-'}%',
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  Expanded(
                    child: _StatItem(
                      label: l10n.afterSaleBindSoh,
                      value: '${battery?.soh ?? '-'}',
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  Expanded(
                    child: _StatItem(
                      label: l10n.afterSaleBindCycle,
                      value: '${battery?.cycle ?? '-'}',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle, required this.l10n});

  final CarVo? vehicle;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: vehicle?.img != null && vehicle!.img!.isNotEmpty
                        ? Image.network(vehicle!.img!, fit: BoxFit.contain)
                        : const Icon(
                            Icons.electric_moped,
                            size: 32,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle?.sn ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _Tag(
                              text:
                                  '${l10n.afterSaleBindVehicleLabel} · ${vehicle?.carModel ?? vehicle?.carType ?? '-'}',
                            ),
                            _Tag(text: vehicle?.carSpec ?? '-'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: l10n.afterSaleBindVin,
                      value: vehicle?.vin ?? '-',
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  Expanded(
                    child: _StatItem(
                      label: l10n.afterSaleBindPlateNumber,
                      value: vehicle?.carNumber ?? '-',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
