import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

class NetworkDebugPage extends StatefulWidget {
  const NetworkDebugPage({super.key});

  @override
  State<NetworkDebugPage> createState() => _NetworkDebugPageState();
}

class _NetworkDebugPageState extends State<NetworkDebugPage> {
  final store = NetworkDebugStore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Debug Logs'),
        actions: [
          IconButton(
            tooltip: 'Showcase',
            icon: const Icon(Icons.dashboard_outlined),
            onPressed: () => context.push('/showcase'),
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: store.clear,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final entries = store.entries;
          if (entries.isEmpty) {
            return const Center(child: Text('No network logs yet'));
          }
          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = entries[index];
              final status = item.isError
                  ? 'ERROR'
                  : (item.completed ? 'DONE' : 'PENDING');
              final statusColor = item.isError
                  ? const Color(0xFFE25C5C)
                  : (item.completed
                        ? const Color(0xFF08983B)
                        : const Color(0xFFED942F));
              return ListTile(
                title: Text('${item.method} ${item.path}'),
                subtitle: Text(
                  '${item.statusCode ?? '-'} / ${item.businessCode ?? '-'}  ·  ${item.durationMs ?? '-'}ms',
                ),
                trailing: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _NetworkDebugDetailPage(entry: item),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NetworkDebugDetailPage extends StatelessWidget {
  const _NetworkDebugDetailPage({required this.entry});

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Request', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SelectableText(requestText),
          const SizedBox(height: 20),
          const Text('Response', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SelectableText(responseText),
        ],
      ),
    );
  }
}
