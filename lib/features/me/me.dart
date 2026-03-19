import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/app/ui.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/core/widgets/image_source_action_sheet.dart';
import 'package:merchant_app/features/debug/network/network_debug_store.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/login/providers/auth_controller.dart';
import 'package:merchant_app/features/me/message_controller.dart';
import 'package:merchant_app/features/me/profile_controller.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
  Timer? _debugPressTimer;
  bool _debugPressActivated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageListProvider.notifier).refresh();
      ref.read(profileProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _debugPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authNotifierProvider);
    final session = AuthSession.instance.current;
    final profileState = ref.watch(profileProvider);
    final profile = profileState.info;
    final rawName = profile?.displayName.trim() ??
        (session != null ? session.name.trim() : '');
    final name = rawName.isNotEmpty ? rawName : context.l10n.tabMe;
    final userId = _formatUserId(profile?.userId);
    final subtitle = userId.isNotEmpty ? userId : '-';
    final avatarUrl = (profile?.avatarUrl?.trim().isNotEmpty ?? false)
        ? profile?.avatarUrl?.trim()
        : session?.avatar.trim();
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
                subtitle: subtitle,
                avatarUrl: avatarUrl,
                showAvatarHint: avatarUrl == null || avatarUrl.isEmpty,
                isUpdating: profileState.updating,
                onEditNickname: () => _editNickname(context, name),
                onEditAvatar: () => _showAvatarSheet(context),
                onLogout: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ProfileCard(actions: allActions),
              ),
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) {
                  _debugPressActivated = false;
                  _debugPressTimer?.cancel();
                  _debugPressTimer = Timer(const Duration(seconds: 7), () {
                    if (_debugPressActivated) return;
                    _debugPressActivated = true;
                    NetworkDebugStore.instance.showFloatingEntry();
                    showToast('已开启悬浮调试入口');
                  });
                },
                onPointerUp: (_) {
                  _debugPressTimer?.cancel();
                },
                onPointerCancel: (_) {
                  _debugPressTimer?.cancel();
                },
                child: const SizedBox(height: 120, width: double.infinity),
              ),
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

  String _formatUserId(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final trimmed = value.trim();
    final atIndex = trimmed.indexOf('@');
    if (atIndex > 0) {
      return trimmed.substring(0, atIndex);
    }
    return trimmed;
  }

  Future<void> _editNickname(BuildContext context, String currentName) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(l10n.profileEditNicknameTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 15,
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
            ],
            decoration: InputDecoration(
              hintText: l10n.profileEditNicknameHint,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => Navigator.of(ctx).pop(controller.text.trim()),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.borderColor),
              ),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
    final trimmed = result?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (result != null) {
        showToast(l10n.profileEditNicknameEmpty);
      }
      return;
    }
    await ref.read(profileProvider.notifier).changeNickName(trimmed);
  }

  Future<void> _showAvatarSheet(BuildContext context) async {
    if (ref.read(profileProvider).updating) return;
    final source = await ImageSourceActionSheet.show(context);
    if (source == null) return;
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image == null) return;
    await ref.read(profileProvider.notifier).changeAvatar(image.path);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.subtitle,
    required this.onLogout,
    required this.onEditNickname,
    required this.onEditAvatar,
    required this.showAvatarHint,
    required this.isUpdating,
    this.avatarUrl,
  });

  final String name;
  final String subtitle;
  final Future<void> Function() onLogout;
  final VoidCallback onEditNickname;
  final VoidCallback onEditAvatar;
  final bool showAvatarHint;
  final bool isUpdating;
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text(context.l10n.logout),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(
                  avatarUrl: avatarUrl,
                  displayName: name,
                  showHint: showAvatarHint,
                  isUpdating: isUpdating,
                  onTap: onEditAvatar,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: onEditNickname,
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
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
  const _Avatar({
    required this.avatarUrl,
    required this.displayName,
    required this.onTap,
    required this.showHint,
    required this.isUpdating,
  });

  final String? avatarUrl;
  final String displayName;
  final VoidCallback onTap;
  final bool showHint;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final avatar = avatarUrl != null && avatarUrl!.isNotEmpty
        ? CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(avatarUrl!),
            onBackgroundImageError: (_, __) {},
          )
        : const CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage(
              'assets/android/mipmap-xxhdpi/icon_def_avatar.webp',
            ),
          );
    return GestureDetector(
      onTap: isUpdating ? null : onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          avatar,
          if (showHint)
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/icon_mine_addphoto.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
          if (isUpdating)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(8),
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
