import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/authorization_record_list.dart';
import 'package:merchant_app/data/models/cabinet_authorization_list.dart';
import 'package:merchant_app/data/models/user_authorization_list.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_authorization_controller.dart';

class CabinetAuthorizationPage extends ConsumerStatefulWidget {
  const CabinetAuthorizationPage({super.key});

  @override
  ConsumerState<CabinetAuthorizationPage> createState() =>
      _CabinetAuthorizationPageState();
}

class _CabinetAuthorizationPageState
    extends ConsumerState<CabinetAuthorizationPage> {
  final _snController = TextEditingController();
  final _keywordController = TextEditingController();
  final _accountController = TextEditingController();
  final _beginController = TextEditingController();
  final _endController = TextEditingController();
  final _permissionIdController = TextEditingController();

  @override
  void dispose() {
    _snController.dispose();
    _keywordController.dispose();
    _accountController.dispose();
    _beginController.dispose();
    _endController.dispose();
    _permissionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetAuthorizationProvider);
    final notifier = ref.read(cabinetAuthorizationProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetAuthTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTextField(
            controller: _snController,
            label: l10n.cabinetAuthSn,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => notifier.queryCabinets(
                    _snController.text.trim(),
                  ),
                  child: Text(l10n.cabinetAuthQueryCabinet),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => notifier.queryRecords(
                    _snController.text.trim(),
                    _accountController.text.trim(),
                  ),
                  child: Text(l10n.cabinetAuthQueryRecord),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.cabinetAuthCabinetList),
          _CabinetList(list: state.cabinetList),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.cabinetAuthUserSection),
          _buildTextField(
            controller: _keywordController,
            label: l10n.cabinetAuthUserKeyword,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => notifier.queryUsers(
              _snController.text.trim(),
              _keywordController.text.trim(),
            ),
            child: Text(l10n.cabinetAuthQueryUser),
          ),
          const SizedBox(height: 8),
          _UserList(list: state.userList),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.cabinetAuthAuthorizeSection),
          _buildTextField(
            controller: _accountController,
            label: l10n.cabinetAuthAccountNo,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _beginController,
            label: l10n.cabinetAuthBeginTime,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _endController,
            label: l10n.cabinetAuthEndTime,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.submitting
                ? null
                : () => _authorize(context, notifier),
            child: state.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.cabinetAuthSubmit),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.cabinetAuthCancelSection),
          _buildTextField(
            controller: _permissionIdController,
            label: l10n.cabinetAuthPermissionId,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _cancel(context, notifier),
            child: Text(l10n.cabinetAuthCancel),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.cabinetAuthRecordSection),
          _RecordList(list: state.recordList),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _authorize(
    BuildContext context,
    CabinetAuthorizationNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final ok = await notifier.authorize(
      sn: _snController.text.trim(),
      accountNo: _accountController.text.trim(),
      beginTime: _beginController.text.trim(),
      endTime: _endController.text.trim(),
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.cabinetAuthSuccess : l10n.cabinetAuthFailed);
  }

  Future<void> _cancel(
    BuildContext context,
    CabinetAuthorizationNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final permissionId =
        int.tryParse(_permissionIdController.text.trim()) ?? 0;
    final ok = await notifier.cancelPermission(
      sn: _snController.text.trim(),
      permissionId: permissionId,
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.cabinetAuthCancelSuccess : l10n.cabinetAuthCancelFailed);
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

class _CabinetList extends StatelessWidget {
  const _CabinetList({required this.list});

  final CabinetAuthorizationList? list;

  @override
  Widget build(BuildContext context) {
    final items = list?.list ?? const [];
    if (items.isEmpty) return const Text('-');
    return Column(
      children: items
          .map(
            (item) => ListTile(
              title: Text(item.stationSn ?? '-'),
              subtitle: Text(item.stationAddress ?? '-'),
            ),
          )
          .toList(),
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({required this.list});

  final UserAuthorizationList? list;

  @override
  Widget build(BuildContext context) {
    final items = list?.list ?? const [];
    if (items.isEmpty) return const Text('-');
    return Column(
      children: items
          .map(
            (item) => ListTile(
              title: Text(item.username ?? '-'),
              subtitle: Text('${item.phone ?? '-'} | ${item.accountNo ?? '-'}'),
            ),
          )
          .toList(),
    );
  }
}

class _RecordList extends StatelessWidget {
  const _RecordList({required this.list});

  final AuthorizationRecordList? list;

  @override
  Widget build(BuildContext context) {
    final items = list?.list ?? const [];
    if (items.isEmpty) return const Text('-');
    return Column(
      children: items
          .map(
            (item) => ListTile(
              title: Text(item['accountNo']?.toString() ?? '-'),
              subtitle: Text(
                '${item['beginTime'] ?? '-'} ~ ${item['endTime'] ?? '-'}',
              ),
            ),
          )
          .toList(),
    );
  }
}
