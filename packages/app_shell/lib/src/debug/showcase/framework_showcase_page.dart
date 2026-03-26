import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../shell_route_paths.dart';

class FrameworkShowcasePage extends StatelessWidget {
  const FrameworkShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nowText = DateFormatUtils.format(DateTime.now());
    final hashText = HashUtils.md5Lower32('universal-template');
    final parsedSn = ScanUtils.getDeviceSn('SN:DEMO-2026');

    return Scaffold(
      appBar: AppBar(title: const Text('Foundation / Design Showcase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: l10n.showcaseStyleTokens,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Primary',
                      style: TextStyle(color: AppColors.onColor(AppColors.primaryColor)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Secondary',
                      style: TextStyle(color: AppColors.onColor(AppColors.secondaryColor)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.showcaseToolkit,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.showcaseCurrentTime(nowText)),
                const SizedBox(height: 6),
                Text('MD5: $hashText'),
                const SizedBox(height: 6),
                Text(l10n.showcaseScanParsed(parsedSn)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.showcaseInteractions,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () {
                    Toast.show(l10n.showcaseToastDemo);
                  },
                  child: const Text('Toast'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    Hud.show();
                    Future.delayed(const Duration(milliseconds: 800), Hud.dismiss);
                  },
                  child: const Text('HUD'),
                ),
                OutlinedButton(
                  onPressed: () {
                    ConfirmDialog.show(
                      context: context,
                      message: l10n.showcaseConfirmDemoMessage,
                      cancelText: l10n.commonCancel,
                      confirmText: l10n.commonConfirm,
                    );
                  },
                  child: const Text('ConfirmDialog'),
                ),
                OutlinedButton(
                  onPressed: () {
                    context.go(ShellRoutePaths.webview);
                  },
                  child: const Text('CommonWebViewPage'),
                ),
                OutlinedButton(
                  onPressed: () {
                    context.go(ShellRoutePaths.scan);
                  },
                  child: const Text('QrScanPage'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.showcaseMedia,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    PhotoGalleryViewer.show(context, const [
                      'https://picsum.photos/id/1015/1200/800',
                      'https://picsum.photos/id/1025/1200/800',
                    ]);
                  },
                  child: const Text('PhotoGalleryViewer'),
                ),
                OutlinedButton(
                  onPressed: () {
                    ImageSourceActionSheet.show(
                      context,
                      cameraLabel: l10n.scanTakePhoto,
                      galleryLabel: l10n.scanChooseFromGallery,
                      cancelLabel: l10n.commonCancel,
                    );
                  },
                  child: const Text('ImageSourceActionSheet'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
