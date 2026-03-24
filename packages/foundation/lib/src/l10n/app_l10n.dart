import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

class AppL10n {
  static const Locale defaultLocale = Locale('en');

  static const List<Locale> supportedLocales = AppLocalizations.supportedLocales;

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      AppLocalizations.localizationsDelegates;

  static AppLocalizations of(BuildContext context) => AppLocalizations.of(context);
}

extension AppL10nBuildContextX on BuildContext {
  AppLocalizations get l10n => AppL10n.of(this);
}
