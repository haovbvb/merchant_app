import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceActionSheet {
  const ImageSourceActionSheet._();

  static Future<ImageSource?> show(
    BuildContext context, {
    int? maxGallerySelection,
    String cameraLabel = 'Take Photo',
    String galleryLabel = 'Choose from Gallery',
    String cancelLabel = 'Cancel',
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE5E5E5)),
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
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(ctx).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        cancelLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF333333),
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
