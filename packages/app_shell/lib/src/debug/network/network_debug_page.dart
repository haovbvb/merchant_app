import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../shell_route_paths.dart';

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
            onPressed: () => context.push(ShellRoutePaths.showcase),
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
                onTap: () => context.push(
                  ShellRoutePaths.networkDebugDetail,
                  extra: item,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
