import 'dart:async';

import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/service_plan.dart';
import 'package:merchant_app/features/work/sales/sell_bind_controller.dart';

class PackageSheet extends ConsumerStatefulWidget {
  const PackageSheet({super.key, required this.notifier});

  final SellBindNotifier notifier;

  static Future<ServicePlanBean?> show(
    BuildContext context,
    SellBindNotifier notifier,
  ) async {
    await notifier.queryPlans('');
    if (!context.mounted) return null;

    return showModalBottomSheet<ServicePlanBean>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PackageSheet(notifier: notifier),
    );
  }

  @override
  ConsumerState<PackageSheet> createState() => _PackageSheetState();
}

class _PackageSheetState extends ConsumerState<PackageSheet> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  ServicePlanBean? _selected;

  @override
  void initState() {
    super.initState();
    final state = ref.read(sellBindProvider);
    _selected = state.selectedPlan;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(sellBindProvider);
    final plans = state.plans;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  l10n.sellBindChoosePackage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF999999), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.sellBindPackageSearchHint,
                        hintStyle: const TextStyle(color: Color(0xFF999999)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (value) {
                        widget.notifier.queryPlans(value.trim());
                      },
                      onChanged: (value) {
                        _searchDebounce?.cancel();
                        _searchDebounce = Timer(
                          const Duration(milliseconds: 1000),
                          () {
                            widget.notifier.queryPlans(value.trim());
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Package list
          Expanded(
            child: state.loadingPlans
                ? const Center(child: SizedBox.shrink())
                : plans.isEmpty
                ? Center(
                    child: Text(
                      l10n.sellBindPlanEmpty,
                      style: const TextStyle(color: Color(0xFF999999)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: plans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      final isSelected = _selected?.infoCode == plan.infoCode;
                      return _PackageItem(
                        plan: plan,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selected = plan);
                          Navigator.of(context).pop(plan);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PackageItem extends StatelessWidget {
  const _PackageItem({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final ServicePlanBean plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = plan.packageAmount?.toStringAsFixed(2) ?? '0.00';
    final hasBatteryType = (plan.batteryType ?? '').isNotEmpty;
    final hasCarType = (plan.carType ?? '').isNotEmpty;
    final typeLabel = hasBatteryType
        ? 'Battery'
        : hasCarType
        ? 'Vehicle'
        : 'Device';
    final typeValue = _valueOrDash(_resolveTypeValue(plan));
    final modelValue = _valueOrDash(_resolveModelValue(plan));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFFEEEEEE),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.infoName ?? '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black06Text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$$price',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B4A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildInfoTag('$typeLabel · $typeValue'),
                      _buildInfoTag('Model · $modelValue'),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  String _valueOrDash(String? value) {
    if (value == null || value.trim().isEmpty || value.trim() == '-') {
      return '-';
    }
    return value;
  }

  String? _resolveTypeValue(ServicePlanBean plan) {
    final carType = plan.carType?.trim();
    if (carType != null && carType.isNotEmpty && carType != '-') {
      return carType;
    }
    final batteryType = plan.batteryType?.trim();
    if (batteryType != null && batteryType.isNotEmpty && batteryType != '-') {
      return batteryType;
    }
    return null;
  }

  String? _resolveModelValue(ServicePlanBean plan) {
    final model = plan.deviceModel?.trim();
    if (model != null && model.isNotEmpty && model != '-') {
      return model;
    }
    return _resolveTypeValue(plan);
  }

  Widget _buildInfoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.black06Text),
      ),
    );
  }
}
