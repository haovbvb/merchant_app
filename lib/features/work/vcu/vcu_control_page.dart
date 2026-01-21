import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/vcu_history.dart';
import 'package:merchant_app/features/work/vcu/vcu_controller.dart';

class VcuControlPage extends ConsumerStatefulWidget {
  const VcuControlPage({super.key});

  @override
  ConsumerState<VcuControlPage> createState() => _VcuControlPageState();
}

class _VcuControlPageState extends ConsumerState<VcuControlPage> {
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _commandController = TextEditingController();
  final DateFormat _timeFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void dispose() {
    _vinController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(vcuProvider);
    final notifier = ref.read(vcuProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.vcuControlTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.vcuControlTab),
              Tab(text: l10n.vcuHistoryTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildControlTab(context, state, notifier),
            _buildHistoryTab(context, state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildControlTab(
    BuildContext context,
    VcuState state,
    VcuNotifier notifier,
  ) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _vinController,
          decoration: InputDecoration(
            labelText: l10n.vcuVinLabel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commandController,
          decoration: InputDecoration(
            labelText: l10n.vcuCommandLabel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: state.sending ? null : () => _send(context, notifier),
          child: state.sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.vcuSendCommand),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    VcuState state,
    VcuNotifier notifier,
  ) {
    final l10n = context.l10n;
    final filtered = _filterHistory(state);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.vcuHistoryFilterAll),
                selected: state.historyFilter == VcuHistoryFilter.all,
                onSelected: (_) =>
                    notifier.setHistoryFilter(VcuHistoryFilter.all),
              ),
              ChoiceChip(
                label: Text(l10n.vcuHistoryFilterRequest),
                selected: state.historyFilter == VcuHistoryFilter.request,
                onSelected: (_) =>
                    notifier.setHistoryFilter(VcuHistoryFilter.request),
              ),
              ChoiceChip(
                label: Text(l10n.vcuHistoryFilterResponse),
                selected: state.historyFilter == VcuHistoryFilter.response,
                onSelected: (_) =>
                    notifier.setHistoryFilter(VcuHistoryFilter.response),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(l10n.vcuHistoryEmpty))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isRequest = item.type == VcuHistoryType.request;
                    final statusText = item.type == VcuHistoryType.response
                        ? (item.success == true
                            ? l10n.vcuHistoryStatusSuccess
                            : l10n.vcuHistoryStatusFailed)
                        : null;
                    final subtitle = [
                      item.vin,
                      if (item.version != null && item.version!.isNotEmpty)
                        item.version!,
                      if (statusText != null) statusText,
                    ].join(' · ');
                    return Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: ListTile(
                        leading: Icon(
                          isRequest ? Icons.upload_rounded : Icons.download_rounded,
                          color: isRequest
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.tertiary,
                        ),
                        title: Text(item.command),
                        subtitle: Text(subtitle),
                        trailing: Text(
                          _timeFormatter.format(
                            DateTime.fromMillisecondsSinceEpoch(item.timestamp),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<VcuHistoryItem> _filterHistory(VcuState state) {
    switch (state.historyFilter) {
      case VcuHistoryFilter.request:
        return state.history
            .where((item) => item.type == VcuHistoryType.request)
            .toList();
      case VcuHistoryFilter.response:
        return state.history
            .where((item) => item.type == VcuHistoryType.response)
            .toList();
      case VcuHistoryFilter.all:
        return state.history;
    }
  }

  Future<void> _send(BuildContext context, VcuNotifier notifier) async {
    final l10n = context.l10n;
    final ok = await notifier.sendCommand(
      vin: _vinController.text.trim(),
      command: _commandController.text.trim(),
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.vcuSendSuccess : l10n.vcuSendFailed);
  }
}
