import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoGalleryViewer {
  static Future<void> show(
    BuildContext context,
    List<String> imageUrls, {
    int initialIndex = 0,
  }) async {
    if (imageUrls.isEmpty) return;
    final safeInitialIndex = initialIndex.clamp(0, imageUrls.length - 1);
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _PhotoGalleryViewerPage(
          imageUrls: imageUrls,
          initialIndex: safeInitialIndex,
        ),
      ),
    );
  }
}

class _PhotoGalleryViewerPage extends StatefulWidget {
  const _PhotoGalleryViewerPage({
    required this.imageUrls,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_PhotoGalleryViewerPage> createState() =>
      _PhotoGalleryViewerPageState();
}

class _PhotoGalleryViewerPageState extends State<_PhotoGalleryViewerPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            builder: (_, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.imageUrls[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.5,
              );
            },
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 18,
            right: 16,
            child: Text(
              '${_currentIndex + 1}/${widget.imageUrls.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
