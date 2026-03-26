import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../profile_route_paths.dart';
import '../providers/language_notifier.dart';
import '../providers/message_controller.dart';
import '../providers/profile_controller.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageListProvider.notifier).refresh();
      ref.read(profileProvider.notifier).refresh();
      ref.read(languageNotifierProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authSnapshot = AuthGatewayRegistry.instance.current.snapshot;
    final profileState = ref.watch(profileProvider);
    final profile = profileState.info;

    final rawName = profile?.displayName.trim() ?? (authSnapshot.name?.trim() ?? '');
    final name = rawName.isNotEmpty ? rawName : '我的';
    final userId = _formatUserId(profile?.userId);
    final subtitle = userId.isNotEmpty ? userId : '-';

    final avatarUrl = (profile?.avatarUrl?.trim().isNotEmpty ?? false)
        ? profile?.avatarUrl?.trim()
      : authSnapshot.avatar?.trim();

    final messageState = ref.watch(messageListProvider);
    final unreadCount = messageState.items.where((item) => item.isRead != 1).length;
    final currentLocale = ref.watch(languageNotifierProvider);

    final actions = [
      _ProfileAction(
        icon: Icons.notifications_outlined,
        iconBg: const Color(0xFFFFD54F),
        label: '消息',
        badgeText: _badgeText(unreadCount),
        onTap: () => context.push(ProfileRoutePaths.messages),
      ),
      _ProfileAction(
        icon: Icons.lock_outline,
        iconBg: const Color(0xFF9575CD),
        label: '修改密码',
        onTap: () => context.push(ProfileRoutePaths.changePassword),
      ),
      _ProfileAction(
        icon: Icons.language,
        iconBg: const Color(0xFF64B5F6),
        label: '语言设置',
        trailingText: _localeLabel(currentLocale),
        onTap: () => context.push(ProfileRoutePaths.language),
      ),
      _ProfileAction(
        icon: Icons.description_outlined,
        iconBg: const Color(0xFF66BB6A),
        label: '服务协议',
        onTap: () => context.push(ProfileRoutePaths.serviceAgreement),
      ),
      _ProfileAction(
        icon: Icons.info_outline,
        iconBg: const Color(0xFFFFB74D),
        label: '关于应用',
        onTap: () => context.push(ProfileRoutePaths.about),
      ),
    ];

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
                  await AuthGatewayRegistry.instance.current.logout();
                  if (!context.mounted) return;
                  context.go('/auth/login');
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ProfileCard(actions: actions),
              ),
              const SizedBox(height: 120),
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
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('修改昵称'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 15,
            inputFormatters: [LengthLimitingTextInputFormatter(15)],
            decoration: const InputDecoration(hintText: '请输入昵称'),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => Navigator.of(ctx).pop(controller.text.trim()),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.borderColor),
              ),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('确认'),
            ),
          ],
        );
      },
    );

    final trimmed = result?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (result != null) {
        showToast('昵称不能为空');
      }
      return;
    }
    await ref.read(profileProvider.notifier).changeNickName(trimmed);
  }

  Future<void> _showAvatarSheet(BuildContext context) async {
    if (ref.read(profileProvider).updating) return;
    final source = await ImageSourceActionSheet.show(
      context,
      cameraLabel: '拍照',
      galleryLabel: '从相册选择',
      cancelLabel: '取消',
    );
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
    return Padding(
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
                  message: '确定退出登录吗？',
                  cancelText: '取消',
                  confirmText: '确认',
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
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              child: const Text('退出登录'),
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
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
            backgroundColor: Color(0xFFECEFF3),
            child: Icon(Icons.person_outline, size: 32, color: Color(0xFF8D95A3)),
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
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: const Color(0xFFDFE3E8)),
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  size: 14,
                  color: Color(0xFF5B6270),
                ),
              ),
            ),
          if (isUpdating)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
            Icon(action.icon, color: const Color(0xFF5B6270), size: 22),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
