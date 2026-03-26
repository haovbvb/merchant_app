import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this._provider);

  final NotifierProvider<AuthNotifier, UserState> _provider;
  ProviderSubscription<UserState>? _subscription;

  void _ensureSubscribed(BuildContext context) {
    if (_subscription != null) {
      return;
    }
    final container = ProviderScope.containerOf(context, listen: false);
    _subscription = container.listen<UserState>(
      _provider,
      (_, __) => notifyListeners(),
      fireImmediately: true,
    );
  }

  void _subscribeIfNeeded() {
    final context = AppNavigator.navigatorKey.currentContext;
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _subscribeIfNeeded());
      return;
    }
    _ensureSubscribed(context);
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _subscribeIfNeeded();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _subscription?.close();
      _subscription = null;
    }
  }
}
