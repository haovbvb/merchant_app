import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foundation/foundation.dart';

class NetworkDebugDetailPage extends StatelessWidget {
  const NetworkDebugDetailPage({
    super.key,
    required this.entry,
  });

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final requestText = prettyJson({
      'method': entry.method,
      'url': entry.url,
      'headers': entry.requestHeaders,
      'query': entry.query,
      'body': entry.requestBody,
    });
    final responseText = prettyJson({
      'statusCode': entry.statusCode,
      'code': entry.businessCode,
      'msg': entry.message,
      'durationMs': entry.durationMs,
      'data': entry.responseBody,
      'error': entry.error,
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.path),
        actions: [
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: () async {
              final text =
                  '=== REQUEST ===\n$requestText\n\n=== RESPONSE ===\n$responseText';
              await Clipboard.setData(ClipboardData(text: text));
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(tabs: [Tab(text: 'Request'), Tab(text: 'Response')]),
            Expanded(
              child: TabBarView(
                children: [
                  _JsonTab(text: requestText),
                  _JsonTab(text: responseText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JsonTab extends StatelessWidget {
  const _JsonTab({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: SelectableText(
        text,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }
}
