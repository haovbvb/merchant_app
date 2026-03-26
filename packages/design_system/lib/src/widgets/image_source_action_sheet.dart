import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../styles/colors.dart';
import '../styles/design.dart';

class ImageSourceActionSheet {
  const ImageSourceActionSheet._();

  static Future<ImageSource?> show(
    BuildContext context, {
    int? maxGallerySelection,
    required String cameraLabel,
    required String galleryLabel,
    required String cancelLabel,
  }) {
    final resolvedGalleryLabel =
        (maxGallerySelection != null && maxGallerySelection > 0)
            ? '$galleryLabel ($maxGallerySelection)'
            : galleryLabel;

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.p16,
              vertical: AppDimens.p16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            cameraLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      AppDivider.thin(),
                      InkWell(
                        onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            resolvedGalleryLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.p12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(ctx).pop(),
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppDimens.p16),
                      child: Text(
                        cancelLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
