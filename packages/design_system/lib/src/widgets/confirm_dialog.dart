import 'package:flutter/material.dart';

import '../styles/colors.dart';
import '../styles/design.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.message,
    required this.confirmText,
    this.cancelText,
    this.singleButton = false,
  }) : assert(singleButton || cancelText != null);

  final String message;
  final String? cancelText;
  final String confirmText;
  final bool singleButton;

  static Future<bool> show({
    required BuildContext context,
    required String message,
    required String cancelText,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmDialog(
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
      ),
    );
    return result ?? false;
  }

  static Future<void> alert({
    required BuildContext context,
    required String message,
    required String buttonText,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmDialog(
        message: message,
        confirmText: buttonText,
        singleButton: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirm = confirmText;

    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppDimens.p24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.p24,
          32,
          AppDimens.p24,
          AppDimens.p24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            if (singleButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.surfaceCard,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
                  ),
                  child: Text(
                    confirm,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textQuaternary,
                        side: BorderSide(color: AppColors.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radius8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
                      ),
                      child: Text(
                        cancelText!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.surfaceCard,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radius8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
                      ),
                      child: Text(
                        confirm,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
