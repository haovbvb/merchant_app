import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';

class SwapVehicleSheet extends StatefulWidget {
  const SwapVehicleSheet({
    super.key,
    required this.vehicles,
    required this.selected,
  });

  final List<CarVo> vehicles;
  final CarVo? selected;

  static Future<CarVo?> show(
    BuildContext context,
    List<CarVo> vehicles,
    CarVo? selected,
  ) {
    return showModalBottomSheet<CarVo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SwapVehicleSheet(
        vehicles: vehicles,
        selected: selected,
      ),
    );
  }

  @override
  State<SwapVehicleSheet> createState() => _SwapVehicleSheetState();
}

class _SwapVehicleSheetState extends State<SwapVehicleSheet> {
  CarVo? _selected;

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
              l10n.swapBindSelectVehicleTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          // 车辆列表
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.vehicles.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: Color(0xFFEEEEEE),
              ),
              itemBuilder: (context, index) {
                final vehicle = widget.vehicles[index];
                final isSelected = _selected?.sn == vehicle.sn;
                return _buildVehicleItem(vehicle, isSelected);
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
                    foregroundColor: const Color(0xFF333333),
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

  Widget _buildVehicleItem(CarVo vehicle, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = vehicle;
        });
        Navigator.of(context).pop(vehicle);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            // 车辆图片
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                image: (vehicle.img ?? '').isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(vehicle.img!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (vehicle.img ?? '').isEmpty
                  ? const Icon(Icons.directions_bike, color: Color(0xFF999999))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.model} · ${vehicle.spec}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SN: ${vehicle.sn ?? '-'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                  if ((vehicle.rentDay ?? 0) > 0) ...[
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
                            text: '${vehicle.rentDay} days',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4CAF50),
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
