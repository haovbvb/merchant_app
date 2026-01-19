import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/pack.dart';
import 'package:merchant_app/features/work/sales/swap_bind_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class SwapBindPage extends ConsumerStatefulWidget {
  const SwapBindPage({super.key});

  @override
  ConsumerState<SwapBindPage> createState() => _SwapBindPageState();
}

class _SwapBindPageState extends ConsumerState<SwapBindPage> {
  final _cardController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(swapBindProvider);
    final notifier = ref.read(swapBindProvider.notifier);
    final info = state.info;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.swapBindTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: l10n.swapBindUserSection),
          const SizedBox(height: 8),
          TextField(
            controller: _cardController,
            decoration: InputDecoration(
              labelText: l10n.swapBindCardNum,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => notifier.queryUser(
                  _cardController.text.trim(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.swapBindVehicleSection),
          const SizedBox(height: 8),
          _CarList(
            l10n: l10n,
            cars: info?.vehicleList ?? const [],
            selected: state.selectedCar,
            onSelected: notifier.selectCar,
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.swapBindBatterySection),
          const SizedBox(height: 8),
          _BatteryList(
            l10n: l10n,
            batteries: info?.batteryList ?? const [],
            selected: state.selectedBatteries,
            onToggle: notifier.toggleBattery,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.loadingPack
                      ? null
                      : () => notifier.queryPackList(),
                  child: state.loadingPack
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.swapBindLoadPackages),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _PackList(
            l10n: l10n,
            packs: state.packs,
            selected: state.selectedPack,
            onSelected: notifier.selectPack,
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.swapBindPaymentSection),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.swapBindPayCash),
                selected: state.paySource == 1,
                onSelected: (_) => notifier.updatePaySource(1),
              ),
              ChoiceChip(
                label: Text(l10n.swapBindPayOnline),
                selected: state.paySource == 2,
                onSelected: (_) => notifier.updatePaySource(2),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: state.submitting
                ? null
                : () => _submit(context, notifier),
            child: state.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.swapBindSubmit),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    SwapBindNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final ok = await notifier.submit(_cardController.text.trim());
    if (!context.mounted) return;
    showToast(ok ? l10n.swapBindSuccess : l10n.swapBindFailed);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}

class _CarList extends StatelessWidget {
  const _CarList({
    required this.l10n,
    required this.cars,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final List<CarVo> cars;
  final CarVo? selected;
  final ValueChanged<CarVo?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (cars.isEmpty) {
      return Text(l10n.swapBindVehicleEmpty);
    }
    return Column(
      children: cars
          .map(
            (car) => RadioListTile<CarVo>(
              value: car,
              groupValue: selected,
              onChanged: onSelected,
              title: Text(car.sn ?? '-'),
              subtitle: Text('${car.model} ${car.spec}'),
            ),
          )
          .toList(),
    );
  }
}

class _BatteryList extends StatelessWidget {
  const _BatteryList({
    required this.l10n,
    required this.batteries,
    required this.selected,
    required this.onToggle,
  });

  final AppLocalizations l10n;
  final List<BatteryVo> batteries;
  final List<BatteryVo> selected;
  final ValueChanged<BatteryVo> onToggle;

  @override
  Widget build(BuildContext context) {
    if (batteries.isEmpty) {
      return Text(l10n.swapBindBatteryEmpty);
    }
    return Column(
      children: batteries
          .map(
            (battery) => CheckboxListTile(
              value: selected.any((item) => item.sn == battery.sn),
              onChanged: (_) => onToggle(battery),
              title: Text(battery.sn ?? '-'),
              subtitle: Text('${battery.model ?? '-'} ${battery.spec ?? ''}'),
            ),
          )
          .toList(),
    );
  }
}

class _PackList extends StatelessWidget {
  const _PackList({
    required this.l10n,
    required this.packs,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final List<Pack> packs;
  final Pack? selected;
  final ValueChanged<Pack> onSelected;

  @override
  Widget build(BuildContext context) {
    if (packs.isEmpty) {
      return Text(l10n.swapBindPackEmpty);
    }
    return Column(
      children: packs
          .map(
            (pack) => RadioListTile<Pack>(
              value: pack,
              groupValue: selected,
              onChanged: (value) {
                if (value != null) onSelected(value);
              },
              title: Text(pack.infoName ?? '-'),
              subtitle: Text(
                '${l10n.swapBindPackAmount}: ${pack.packageAmount ?? '-'}',
              ),
            ),
          )
          .toList(),
    );
  }
}
