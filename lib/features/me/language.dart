import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/me/providers/language_notifier.dart';

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageNotifierProvider);
    final options = _buildOptions(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileLanguage)),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.locale == currentLocale;
          return Container(
            color: Colors.white,
            child: ListTile(
              title: Text(
                option.title,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xE60C0C0D),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Color(0xFF56B327))
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

  List<_LanguageOption> _buildOptions(BuildContext context) => [
    _LanguageOption(
      locale: const Locale('en'),
      title: 'English',
    ),
    _LanguageOption(
      locale: const Locale('zh'),
      title: '简体中文',
    ),
  ];
}

class _LanguageOption {
  const _LanguageOption({
    required this.locale,
    required this.title,
  });

  final Locale locale;
  final String title;
}
