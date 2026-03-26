import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

import '../providers/profile_controller.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _submitting = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = AuthGatewayRegistry.instance.current.snapshot;
    final account = _formatAccount(session.name, session.emailCode);

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: AppBar(
        title: Text(l10n.changePasswordTitle),
        centerTitle: true,
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.p16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.p6),
                child: Text(
                  l10n.changePasswordCurrentAccount(account),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textQuaternary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.p16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.p6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.iconMuted, size: 20),
                    const SizedBox(width: AppDimens.p8),
                    Expanded(
                      child: Text(
                        l10n.changePasswordTips,
                        style: const TextStyle(
                          color: AppColors.textPlaceholder,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.p16),
              Container(
                color: AppColors.surfaceCard,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.p16,
                  vertical: AppDimens.p16,
                ),
                child: Column(
                  children: [
                    _PasswordField(
                      controller: _oldController,
                      label: l10n.changePasswordOldPassword,
                      hint: l10n.changePasswordOldPasswordHint,
                      requiredMessage: l10n.changePasswordFieldRequired,
                      tooShortMessage: l10n.passwordTooShort,
                      obscure: _obscureOld,
                      onToggle: () => setState(() => _obscureOld = !_obscureOld),
                    ),
                    const SizedBox(height: AppDimens.p20),
                    _PasswordField(
                      controller: _newController,
                      label: l10n.changePasswordNewPassword,
                      hint: l10n.changePasswordNewPasswordHint,
                      requiredMessage: l10n.changePasswordFieldRequired,
                      tooShortMessage: l10n.passwordTooShort,
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: AppDimens.p20),
                    _PasswordField(
                      controller: _confirmController,
                      label: l10n.changePasswordConfirmPassword,
                      hint: l10n.changePasswordConfirmPasswordHint,
                      requiredMessage: l10n.changePasswordFieldRequired,
                      tooShortMessage: l10n.passwordTooShort,
                      obscure: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.p16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.surfaceCard,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radius8),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surfaceCard,
                            ),
                          )
                        : Text(
                            l10n.changePasswordSubmit,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAccount(String? name, String? emailCode) {
    final safeName = (name ?? '').trim();
    final safeCode = (emailCode ?? '').trim();
    if (safeName.isEmpty) return '-';
    if (safeCode.isEmpty) return safeName;
    return '$safeName@$safeCode';
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final oldPwd = _oldController.text.trim();
    final newPwd = _newController.text.trim();
    final confirmPwd = _confirmController.text.trim();

    if (newPwd != confirmPwd) {
      _showSnack(l10n.changePasswordMismatch);
      return;
    }

    setState(() => _submitting = true);
    final success = await ref.read(profileProvider.notifier).changePassword(
      oldPassword: oldPwd,
      newPassword: newPwd,
      confirmPassword: confirmPwd,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      _showSnack(l10n.changePasswordSuccess);
      Navigator.of(context).pop();
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.requiredMessage,
    required this.tooShortMessage,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String requiredMessage;
  final String tooShortMessage;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textQuaternary,
          ),
        ),
        const SizedBox(height: AppDimens.p8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textDisabled,
              fontSize: 15,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textPlaceholder,
                size: 20,
              ),
              onPressed: onToggle,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
            border: const UnderlineInputBorder(),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.inputBorderDefault),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.inputBorderFocused, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return requiredMessage;
            }
            if (value.trim().length < 6) {
              return tooShortMessage;
            }
            return null;
          },
        ),
      ],
    );
  }
}
