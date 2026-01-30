import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/ui.dart';
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/login/providers/auth_controller.dart';
import 'package:merchant_app/features/me/message_controller.dart';
import 'package:merchant_app/features/me/providers/language_notifier.dart';
class _ProfileAction {
  const _ProfileAction({
    this.icon,
    this.iconPath,
    required this.iconBg,
    required this.label,
    this.badgeText,
    this.trailingText,
    this.onTap,
  }) : assert(icon != null || iconPath != null, 'Either icon or iconPath must be provided');

  final IconData? icon;
  final String? iconPath;
  final Color iconBg;
  final String label;
  final String? badgeText;
  final String? trailingText;
  final VoidCallback? onTap;
}

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageListProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authNotifierProvider);
    final session = AuthSession.instance.current;
    final rawName = session != null ? session.name.trim() : '';
    final rawPhone = session != null ? session.phone.trim() : '';
    final name = rawName.isNotEmpty ? rawName : context.l10n.tabMe;
    final phone = rawPhone.isNotEmpty ? rawPhone : context.l10n.profileGreeting;
    final avatarUrl = session?.avatar.trim();
    final messageState = ref.watch(messageListProvider);
    final unreadCount = messageState.items
        .where((item) => item.isRead != 1)
        .length;
    final currentLocale = ref.watch(languageNotifierProvider);

    final actionsPrimary = [
      _ProfileAction(
        iconPath: 'assets/android/mipmap-xxhdpi/icon_notification.webp',
        iconBg: const Color(0xFFFFD54F),
        label: context.l10n.profileMessage,
        badgeText: _badgeText(unreadCount),
        onTap: () => AppRouter.router.push(AppRouter.messagePath),
      ),
      _ProfileAction(
        iconPath: 'assets/android/mipmap-xxhdpi/icon_change_psw.webp',
        iconBg: const Color(0xFF9575CD),
        label: context.l10n.profileChangePassword,
        onTap: () => AppRouter.router.push(AppRouter.changePasswordPath),
      ),
    ];

    final actionsSecondary = [
      _ProfileAction(
        iconPath: 'assets/android/mipmap-xxhdpi/icon_language_setting.webp',
        iconBg: const Color(0xFF64B5F6),
        label: context.l10n.profileLanguage,
        trailingText: _localeLabel(currentLocale),
        onTap: () => AppRouter.router.push(AppRouter.languagePath),
      ),
      _ProfileAction(
        iconPath: 'assets/android/mipmap-xxhdpi/icon_user_agreement.png',
        iconBg: const Color(0xFF66BB6A),
        label: context.l10n.profileUserAgreement,
        onTap: () => AppRouter.router.push(AppRouter.serviceAgreementPath),
      ),
      _ProfileAction(
        iconPath: 'assets/android/mipmap-xxhdpi/icon_about_app.webp',
        iconBg: const Color(0xFFFFB74D),
        label: context.l10n.profileAbout,
        onTap: () => AppRouter.router.push(AppRouter.aboutPath),
      ),
    ];

    final allActions = [...actionsPrimary, ...actionsSecondary];

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(
                name: name,
                subtitle: phone,
                avatarUrl: avatarUrl,
                onLogout: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ProfileCard(actions: allActions),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String? _badgeText(int count) {
    if (count <= 0) return null;
    return count > 99 ? '99+' : count.toString();
  }

  String _localeLabel(Locale locale) {
    if (locale.languageCode.toLowerCase().startsWith('zh')) {
      return '简体中文';
    }
    return 'English';
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.subtitle,
    required this.onLogout,
    this.avatarUrl,
  });

  final String name;
  final String subtitle;
  final Future<void> Function() onLogout;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context: context,
                    message: context.l10n.logoutConfirmMessage,
                    cancelText: context.l10n.cancel,
                    confirmText: context.l10n.confirm,
                  );
                  if (confirmed) {
                    await onLogout();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.black06Text,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                child: Text(context.l10n.logout),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(avatarUrl: avatarUrl, displayName: name),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.black09Text,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.black04Text,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: $subtitle',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.black05Text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl, required this.displayName});

  final String? avatarUrl;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final sanitized = displayName.trim();
    final initials = sanitized.isNotEmpty
        ? sanitized.substring(0, 1).toUpperCase()
        : '?';
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundImage: NetworkImage(avatarUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 32,
      child: Text(initials, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.actions});

  final List<_ProfileAction> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            offset: Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            _ProfileActionTile(action: actions[i]),
            if (i != actions.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: AppColors.borderColor,
              ),
          ],
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({required this.action});

  final _ProfileAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: action.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              child: action.iconPath != null
                  ? Image.asset(
                      action.iconPath!,
                      fit: BoxFit.contain,
                    )
                  : Icon(action.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                action.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.black09Text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (action.trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  action.trailingText!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.black05Text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (action.badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6F61),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  action.badgeText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Color(0xFFB0B8C4)),
          ],
        ),
      ),
    );
  }
}
