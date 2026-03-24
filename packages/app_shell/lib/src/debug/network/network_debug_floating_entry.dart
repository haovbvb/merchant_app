import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

import 'network_debug_page.dart';

class NetworkDebugFloatingEntry extends StatefulWidget {
  const NetworkDebugFloatingEntry({super.key});

  @override
  State<NetworkDebugFloatingEntry> createState() =>
      _NetworkDebugFloatingEntryState();
}

class _NetworkDebugFloatingEntryState extends State<NetworkDebugFloatingEntry> {
  Offset _offset = const Offset(0, 140);
  final NetworkDebugStore _store = NetworkDebugStore.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        if (!_store.floatingEntryVisible) {
          return const SizedBox.shrink();
        }

        final size = MediaQuery.of(context).size;
        const buttonSize = 44.0;
        final clampedDx = _offset.dx.clamp(0.0, size.width - buttonSize);
        final clampedDy = _offset.dy.clamp(0.0, size.height - buttonSize - 24);

        return Positioned(
          left: clampedDx,
          top: clampedDy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _offset += details.delta;
              });
            },
            onTap: () {
              AppNavigator.navigatorKey.currentState?.push(
                MaterialPageRoute(builder: (_) => const NetworkDebugPage()),
              );
            },
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: const Color(0xCC000000),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.bug_report_outlined, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
