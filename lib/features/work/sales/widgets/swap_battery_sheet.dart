import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';

class SwapBatterySheet extends StatefulWidget {
  const SwapBatterySheet({
    super.key,
    required this.batteries,
    required this.selected,
  });

  final List<BatteryVo> batteries;
  final BatteryVo? selected;

  static Future<BatteryVo?> show(
    BuildContext context,
    List<BatteryVo> batteries,
    BatteryVo? selected,
  ) {
    return showModalBottomSheet<BatteryVo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SwapBatterySheet(
        batteries: batteries,
        selected: selected,
      ),
    );
  }

  @override
  State<SwapBatterySheet> createState() => _SwapBatterySheetState();
}

class _SwapBatterySheetState extends State<SwapBatterySheet> {
  BatteryVo? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.swapBindSelectBatteryTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black06Text,
              ),
            ),
          ),
          // 电池列表
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.batteries.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: Color(0xFFEEEEEE),
              ),
              itemBuilder: (context, index) {
                final battery = widget.batteries[index];
                final isSelected = _selected?.sn == battery.sn;
                return _buildBatteryItem(battery, isSelected);
              },
            ),
          ),
          // 取消按钮
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black06Text,
                    side: const BorderSide(color: Color(0xFFEEEEEE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryItem(BatteryVo battery, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = battery;
        });
        Navigator.of(context).pop(battery);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.transparent,
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
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryColor : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : const Color(0xFFCCCCCC),
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
