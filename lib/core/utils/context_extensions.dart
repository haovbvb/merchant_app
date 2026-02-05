import 'package:flutter/widgets.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

extension LocalizationBuildContextX on BuildContext {
  AppLocalizations get l10n {
    final value = AppLocalizations.of(this);
    if (value != null) return value;
    Locale locale;
    try {
      locale = Localizations.localeOf(this);
    } catch (_) {
      locale = const Locale('en');
    }
    return lookupAppLocalizations(locale);
  }
}
