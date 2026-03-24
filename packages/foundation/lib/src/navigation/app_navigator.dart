import 'package:flutter/widgets.dart';

class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context =>
      navigatorKey.currentState?.context ?? navigatorKey.currentContext;

  static OverlayState? get overlay {
    final state = navigatorKey.currentState;
    if (state != null) {
      return state.overlay;
    }
    final ctx = context;
    if (ctx != null) {
      return Overlay.of(ctx, rootOverlay: true);
    }
    return null;
  }
}
