import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';

class EntryScanPage extends StatefulWidget {
  const EntryScanPage({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  State<EntryScanPage> createState() => _EntryScanPageState();
}

class _EntryScanPageState extends State<EntryScanPage> {
  final TextEditingController _snController = TextEditingController();

  @override
  void dispose() {
    _snController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.subtitle != null) ...[
              Text(
                widget.subtitle!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _snController,
              decoration: InputDecoration(
                labelText: l10n.entrySnLabel,
                hintText: l10n.entrySnHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () => _scan(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _submit(context),
              child: Text(l10n.entrySubmitAction),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scan(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
  }

  void _submit(BuildContext context) {
    final value = _snController.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }
}
