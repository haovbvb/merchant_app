import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/car_type.dart';
import 'package:merchant_app/features/work/entry/battery_ship_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class VehicleEntryPage extends StatefulWidget {
  const VehicleEntryPage({super.key});

  @override
  State<VehicleEntryPage> createState() => _VehicleEntryPageState();
}

class _VehicleEntryPageState extends State<VehicleEntryPage> {
  final ApiService _api = ApiService();
  final List<_VehicleItem> _items = [];
  List<CarType> _types = [];
  CarType? _selected;
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    setState(() => _loading = true);
    final response = await _api.get<List<CarType>>(
      ApiPath.vehicleModelList,
      parser: (json) => (json as List<dynamic>?)
              ?.map((item) => CarType.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <CarType>[],
    );
    setState(() {
      _loading = false;
      _types = response.result ?? [];
      _selected = _types.isNotEmpty ? _types.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vehicleEntryTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<CarType>(
                  initialValue: _selected,
                  items: _types
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text('${type.model ?? '-'} ${type.modelName ?? ''}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selected = value),
                  decoration: InputDecoration(
                    labelText: l10n.entryModelLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.entryDeviceListTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addByScan,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(l10n.entryScanAdd),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _addManual,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.entryManualAdd),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_items.isEmpty)
                  _EmptyCard(text: l10n.entryListEmpty)
                else
                  ..._items.asMap().entries.map(
                        (entry) => Card(
                          child: ListTile(
                            title: Text(entry.value.sn),
                            subtitle: Text(
                              '${l10n.entryVinLabel}: ${entry.value.vin}\n'
                              '${l10n.entryCtrlIdLabel}: ${entry.value.ctrlId}',
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editItem(entry.key);
                                } else if (value == 'delete') {
                                  setState(() => _items.removeAt(entry.key));
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text(l10n.entryEditAction),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(l10n.entryDeleteAction),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(l10n.entrySubmitAction),
                ),
              ],
            ),
    );
  }

  Future<void> _addByScan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(
          parseDeviceSn: true,
          deviceType: 2,
        ),
      ),
    );
    if (result == null || result.isEmpty) return;
    setState(() => _items.add(_VehicleItem(sn: result)));
  }

  Future<void> _addManual() async {
    final item = await _showItemDialog();
    if (item == null) return;
    setState(() => _items.add(item));
  }

  Future<void> _editItem(int index) async {
    final item = await _showItemDialog(initial: _items[index]);
    if (item == null) return;
    setState(() => _items[index] = item);
  }

  Future<_VehicleItem?> _showItemDialog({_VehicleItem? initial}) async {
    final l10n = context.l10n;
    final snController = TextEditingController(text: initial?.sn ?? '');
    final vinController = TextEditingController(text: initial?.vin ?? '');
    final ctrlController = TextEditingController(text: initial?.ctrlId ?? '');

    final result = await showDialog<_VehicleItem>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(initial == null
              ? l10n.entryAddDeviceTitle
              : l10n.entryEditDeviceTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: snController,
                decoration: InputDecoration(labelText: l10n.entrySnLabel),
              ),
              TextField(
                controller: vinController,
                decoration: InputDecoration(labelText: l10n.entryVinLabel),
              ),
              TextField(
                controller: ctrlController,
                decoration: InputDecoration(labelText: l10n.entryCtrlIdLabel),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(
                _VehicleItem(
                  sn: snController.text.trim(),
                  vin: vinController.text.trim(),
                  ctrlId: ctrlController.text.trim(),
                ),
              ),
              child: Text(l10n.entryConfirmAction),
            ),
          ],
        );
      },
    );

    return result;
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (_selected == null) {
      showToast(l10n.entryModelRequired);
      return;
    }
    if (_items.isEmpty) {
      showToast(l10n.entryListEmpty);
      return;
    }
    final invalidVin = _items.any((item) => item.vin.trim().isEmpty);
    if (invalidVin) {
      showToast(l10n.entryVinRequired);
      return;
    }
    setState(() => _submitting = true);
    await _api.post<Object>(
      ApiPath.vehicleRegister,
      data: {
        'model': _selected?.model ?? '',
        'list': _items.map((item) => item.toJson()).toList(),
      },
      parser: (json) => json ?? Object(),
    );
    final sns = _items.map((item) => item.sn).toList();
    setState(() {
      _submitting = false;
    });
    if (!mounted) return;
    showToast(l10n.entrySubmitSuccess);
    final goToTransfer = await _showTransferDialog();
    if (!mounted) return;
    if (goToTransfer == true) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BatteryShipPage(
            deviceType: 2,
            initialSns: sns,
          ),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _items.clear());
  }

  Future<bool?> _showTransferDialog() async {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.entrySubmitDoneTitle),
          content: Text(l10n.entrySubmitDoneMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.entryStayAction),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.entryGoToTransferAction),
            ),
          ],
        );
      },
    );
  }
}

class _VehicleItem {
  final String sn;
  final String vin;
  final String ctrlId;

  const _VehicleItem({
    required this.sn,
    this.vin = '',
    this.ctrlId = '',
  });

  Map<String, dynamic> toJson() => {
        'sn': sn,
        'vin': vin,
        'ctrlId': ctrlId,
      };
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text),
      ),
    );
  }
}
