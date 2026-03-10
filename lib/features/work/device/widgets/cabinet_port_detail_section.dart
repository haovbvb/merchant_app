import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';

class CabinetPortViewItem {
  const CabinetPortViewItem({
    required this.portNo,
    this.status = 0,
    this.batteryStatus = 0,
    this.batterySoc = 0,
    this.swapFlag = 0,
    this.batterySn = '',
  });

  final int portNo;
  final int status;
  final int batteryStatus;
  final int batterySoc;
  final int swapFlag;
  final String batterySn;

  bool get isDisabled => status == 0;
  bool get hasBattery => batteryStatus == 1;
}

class CabinetPortDetailSection extends StatelessWidget {
  const CabinetPortDetailSection({
    super.key,
    required this.l10n,
    required this.ports,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.emptyText,
    required this.loading,
    this.showSetup = false,
    this.onSetup,
    this.onRefresh,
  });

  final dynamic l10n;
  final List<CabinetPortViewItem> ports;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final String emptyText;
  final bool loading;
  final bool showSetup;
  final ValueChanged<CabinetPortViewItem>? onSetup;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final freeCount = ports.where((p) => p.batteryStatus == 0).length;
    final disabledCount = ports.where((p) => p.status == 0).length;
    final occupiedCount = ports.where((p) => p.batteryStatus == 1).length;

    List<CabinetPortViewItem> filteredPorts;
    switch (selectedFilter) {
      case 'available':
        filteredPorts = ports.where((p) => p.batteryStatus == 0).toList();
        break;
      case 'disabled':
        filteredPorts = ports.where((p) => p.status == 0).toList();
        break;
      case 'inuse':
        filteredPorts = ports.where((p) => p.batteryStatus == 1).toList();
        break;
      default:
        filteredPorts = ports;
    }

    final content = filteredPorts.isEmpty && !loading
        ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 80),
            children: [
              Center(
                child: Text(
                  emptyText,
                  style: const TextStyle(color: Color(0xFF999999)),
                ),
              ),
            ],
          )
        : GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: filteredPorts.length,
            itemBuilder: (context, index) {
              final item = filteredPorts[index];
              return _CabinetPortCard(
                item: item,
                l10n: l10n,
                showSetup: showSetup,
                onSetup: onSetup == null ? null : () => onSetup!(item),
              );
            },
          );

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: [
              _PortFilterChip(
                label: l10n.deviceDetailPortFilterAll,
                isSelected: selectedFilter == 'all',
                onTap: () => onFilterChanged('all'),
              ),
              _PortFilterChip(
                label: '${l10n.deviceDetailPortFilterAvailable}  $freeCount',
                isSelected: selectedFilter == 'available',
                onTap: () => onFilterChanged('available'),
              ),
              _PortFilterChip(
                label: '${l10n.deviceDetailPortFilterDisabled}  $disabledCount',
                isSelected: selectedFilter == 'disabled',
                onTap: () => onFilterChanged('disabled'),
              ),
              _PortFilterChip(
                label: '${l10n.deviceDetailPortFilterInUse}  $occupiedCount',
                isSelected: selectedFilter == 'inuse',
                onTap: () => onFilterChanged('inuse'),
              ),
            ],
          ),
        ),
        Expanded(
          child: onRefresh == null
              ? content
              : RefreshIndicator(
                  onRefresh: onRefresh!,
                  child: content,
                ),
        ),
      ],
    );
  }
}

class _PortFilterChip extends StatelessWidget {
  const _PortFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : const Color(0xFFEEEEEE),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? AppColors.primaryColor : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}

class _CabinetPortCard extends StatelessWidget {
  const _CabinetPortCard({
    required this.item,
    required this.l10n,
    required this.showSetup,
    this.onSetup,
  });

  final CabinetPortViewItem item;
  final dynamic l10n;
  final bool showSetup;
  final VoidCallback? onSetup;

  @override
  Widget build(BuildContext context) {
    final soc = item.batterySoc;
    final swapFlag = item.swapFlag;
    final isDisabled = item.isDisabled;
    final hasBattery = item.hasBattery;

    final socColor = isDisabled
        ? const Color(0x330C0C0D)
        : (swapFlag == 0 ? const Color(0xFFFA4B51) : const Color(0xFF0ABF83));

    final portBadgeColor = isDisabled
        ? const Color(0x330C0C0D)
        : hasBattery
            ? const Color(0xE60C0C0D)
            : const Color(0x330C0C0D);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDisabled ? const Color(0xFFFAFAFA) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: portBadgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${item.portNo}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (!isDisabled && hasBattery && swapFlag == 1)
                Row(
                  children: [
                    Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_cabin_enable.webp',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      l10n.deviceDetailPortReplaceable,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0ABF83),
                      ),
                    ),
                  ],
                ),
              if (isDisabled)
                Row(
                  children: [
                    Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_cabin_unable.webp',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      l10n.deviceDetailPortDisabled,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xE60C0C0D),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const Spacer(),
          if (hasBattery)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BatteryCapacityView(
                  soc: soc,
                  swapFlag: swapFlag,
                  isDisabled: isDisabled,
                ),
                const SizedBox(width: 4),
                Text(
                  '$soc%',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: socColor,
                  ),
                ),
              ],
            )
          else
            Center(
              child: Text(
                l10n.deviceDetailPortAvailable,
                style: const TextStyle(fontSize: 17, color: Color(0x800C0C0D)),
              ),
            ),
          const SizedBox(height: 4),
          if (hasBattery)
            Text(
              'SN: ${item.batterySn}',
              style: TextStyle(
                fontSize: 12,
                color: isDisabled ? const Color(0x330C0C0D) : const Color(0x800C0C0D),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),
          if (showSetup && onSetup != null)
            SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton.icon(
                onPressed: onSetup,
                icon: Icon(
                  Icons.settings_outlined,
                  size: 16,
                  color: isDisabled ? const Color(0xFFCCCCCC) : const Color(0xFF666666),
                ),
                label: Text(
                  l10n.deviceDetailPortSetup,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDisabled ? const Color(0xFFCCCCCC) : const Color(0xFF666666),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: BorderSide(
                    color: isDisabled ? const Color(0xFFEEEEEE) : const Color(0xFFDDDDDD),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BatteryCapacityView extends StatelessWidget {
  const _BatteryCapacityView({
    required this.soc,
    required this.swapFlag,
    required this.isDisabled,
  });

  final int soc;
  final int swapFlag;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final bgImage = isDisabled
        ? 'assets/android/mipmap-xxhdpi/bg_battery_capacity_disable.webp'
        : 'assets/android/mipmap-xxhdpi/bg_battery_capacity.webp';

    final fillColor = isDisabled
        ? const Color(0x330C0C0D)
        : (swapFlag == 0 ? const Color(0xFFFA4B51) : const Color(0xFF0ABF83));

    final progress = (soc / 100.0).clamp(0.0, 1.0);

    return SizedBox(
      width: 22,
      height: 18,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final left = w * 0.08;
          final top = h * 0.18;
          final maxFillWidth = w * 0.72;
          final fillHeight = h * 0.64;

          return Stack(
            children: [
              Image.asset(bgImage, width: w, height: h, fit: BoxFit.fill),
              Positioned(
                left: left,
                top: top,
                child: Container(
                  width: progress * maxFillWidth,
                  height: fillHeight,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}