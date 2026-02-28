import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/login/providers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _agreedToTerms = false;

  bool get _hasCredentialsInput =>
      _nameController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _nameController.removeListener(_onInputChanged);
    _passwordController.removeListener(_onInputChanged);
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authNotifierProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/AppIcon_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.eco,
                            color: AppColors.primaryColor,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.loginBrandTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.black09Text,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 60),
                  _AccountField(controller: _nameController),
                  const SizedBox(height: 24),
                  _PasswordField(
                    controller: _passwordController,
                    obscurePassword: _obscurePassword,
                    onToggleVisibility: () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
                  ),
                  const SizedBox(height: 32),
                  _LoginButton(
                    isSubmitting: _isSubmitting,
                    agreedToTerms: _agreedToTerms,
                    hasCredentialsInput: _hasCredentialsInput,
                    onPressed: _onSubmit,
                  ),
                  const SizedBox(height: 20),
                  _TermsCheckbox(
                    agreed: _agreedToTerms,
                    onChanged: (value) => setState(() {
                      _agreedToTerms = value ?? false;
                    }),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.loginAgreeTermsToast)),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final notifier = ref.read(authNotifierProvider.notifier);

    setState(() => _isSubmitting = true);
    try {
      final success = await notifier.login(name: name, password: password);
      if (success) {
        await _saveCredentials(name, password);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final account = prefs.getString(StorageKeys.loginAccount) ?? '';
    final password = prefs.getString(StorageKeys.loginPassword) ?? '';
    if (account.isNotEmpty) {
      _nameController.text = account;
    }
    if (password.isNotEmpty) {
      _passwordController.text = password;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveCredentials(String account, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.loginAccount, account);
    await prefs.setString(StorageKeys.loginPassword, password);
  }
}

class _AccountField extends StatelessWidget {
  const _AccountField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: AppColors.black09Text, fontSize: 16),
      decoration: InputDecoration(
        hintText: l10n.loginAccountHint,
        hintStyle: TextStyle(color: AppColors.black04Text, fontSize: 16),
        prefixIcon: Icon(
          Icons.person_outline,
          color: AppColors.black05Text,
          size: 22,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.black02Text),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.black02Text),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.nameRequired;
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscurePassword,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      obscureText: obscurePassword,
      style: TextStyle(color: AppColors.black09Text, fontSize: 16),
      decoration: InputDecoration(
        hintText: l10n.loginPasswordHint,
        hintStyle: TextStyle(color: AppColors.black04Text, fontSize: 16),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: AppColors.black05Text,
          size: 22,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.black04Text,
            size: 22,
          ),
          onPressed: onToggleVisibility,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.black02Text),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.black02Text),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.passwordRequired;
        }
        if (value.length < 6) {
          return l10n.passwordTooShort;
        }
        return null;
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.isSubmitting,
    required this.agreedToTerms,
    required this.hasCredentialsInput,
    required this.onPressed,
  });

  final bool isSubmitting;
  final bool agreedToTerms;
  final bool hasCredentialsInput;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isActive = agreedToTerms && hasCredentialsInput && !isSubmitting;
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isActive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:  AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
                agreedToTerms ? l10n.loginButtonConfirm : l10n.login,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.agreed, required this.onChanged});

  final bool agreed;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: agreed,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: agreed ? AppColors.primaryColor : AppColors.black03Text,
              width: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.black06Text,
                fontSize: 14,
                height: 1.4,
              ),
              children: [
                TextSpan(text: l10n.loginAgreePrefix),
                TextSpan(
                  text: l10n.profileUserAgreement,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.none,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      AppRouter.router.push(AppRouter.userAgreementPath);
                    },
                ),
                TextSpan(text: l10n.loginAgreeAnd),
                TextSpan(
                  text: l10n.profilePrivacyPolicy,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.none,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      AppRouter.router.push(AppRouter.privacyPolicyPath);
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
