import 'dart:async';

import 'package:flutter/material.dart';

import '../navigation/app_navigator.dart';

class Toast {
  Toast._();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _dismiss();

    final overlay = AppNavigator.overlay;
    if (overlay == null) {
      return;
    }

    _currentEntry = OverlayEntry(
      builder: (ctx) => Positioned.fill(
        child: IgnorePointer(
          ignoring: true,
          child: SafeArea(
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentEntry!);
    _dismissTimer = Timer(duration, _dismiss);
  }

  static void dismiss() => _dismiss();

  static void _dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

void showToast(
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  Toast.show(message, duration: duration);
}
