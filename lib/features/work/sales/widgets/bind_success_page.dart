import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/toast.dart';

class BindSuccessPage extends StatelessWidget {
  const BindSuccessPage({
    super.key,
    required this.appBarTitle,
    required this.successTitle,
    required this.messageSpans,
    required this.documentNo,
    required this.documentNoLabel,
    required this.copiedToast,
    required this.returnButtonText,
    required this.onBack,
    required this.onReturn,
    this.successIconSize = 40,
    this.successTitleSize = 20,
  });

  final String appBarTitle;
  final String successTitle;
  final List<InlineSpan> messageSpans;
  final String documentNo;
  final String documentNoLabel;
  final String copiedToast;
  final String returnButtonText;
  final VoidCallback onBack;
  final VoidCallback onReturn;
  final double successIconSize;
  final double successTitleSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: onBack,
        ),
        title: Text(
          appBarTitle,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: successIconSize),
              ),
              const SizedBox(height: 16),
              Text(
                successTitle,
                style: TextStyle(
                  fontSize: successTitleSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                  children: messageSpans,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      documentNoLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          documentNo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black06Text,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: documentNo));
                            showToast(copiedToast);
                          },
                          child: const Icon(
                            Icons.copy,
                            size: 18,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onReturn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(returnButtonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
