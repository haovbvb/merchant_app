import 'dart:async';

import 'package:flutter/material.dart';

import '../navigation/app_navigator.dart';

class Hud {
  Hud._();

  static OverlayEntry? _entry;
  static int _counter = 0;
  static Timer? _dismissTimer;

  static void show() {
    if (_entry != null) {
      _counter++;
      _dismissTimer?.cancel();
      _dismissTimer = null;
      return;
    }

    final overlayState = AppNavigator.overlay;
    if (overlayState == null) {
      return;
    }

    _counter = 1;
    _entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.2),
          alignment: Alignment.center,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: SizedBox.square(
                dimension: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_entry!);
  }

  static void dismiss() {
    if (_counter > 0) {
      _counter--;
    }
    if (_counter > 0) {
      return;
    }

    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(milliseconds: 150), () {
      _entry?.remove();
      _entry = null;
      _dismissTimer = null;
    });
  }
}
