import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  Size get screenSize => MediaQuery.sizeOf(this);

  bool get isDarkMode => theme.brightness == Brightness.dark;

  void hideKeyboard() {
    final scope = FocusScope.of(this);
    if (!scope.hasPrimaryFocus && scope.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}
