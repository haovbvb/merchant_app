import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

import '../providers/language_notifier.dart';

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(languageNotifierProvider);
    final options = _buildOptions(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageSettingsTitle)),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.locale == currentLocale;
          return Container(
            color: AppColors.surfaceCard,
            child: ListTile(
              title: Text(
                option.title,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppColors.primaryColor)
                  : null,
              onTap: () => _onSelect(ref, option.locale, context),
            ),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: options.length,
      ),
    );
  }

  void _onSelect(WidgetRef ref, Locale locale, BuildContext context) {
    ref.read(languageNotifierProvider.notifier).setLocale(locale);
    Navigator.of(context).pop();
  }

  List<_LanguageOption> _buildOptions(BuildContext context) {
    final l10n = context.l10n;
    return [
      _LanguageOption(locale: const Locale('en'), title: l10n.languageEnglish),
      _LanguageOption(locale: const Locale('zh'), title: l10n.languageChineseSimplified),
    ];
  }
}

class _LanguageOption {
  const _LanguageOption({required this.locale, required this.title});

  final Locale locale;
  final String title;
}
