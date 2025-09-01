import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final path = imageUrls[index];
          return InteractiveViewer(
            child: buildImage(path, fit: BoxFit.contain),
          );
        },
      ),
    );
  }

  Widget buildImage(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.isEmpty) {
      return Center(
        child: Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    } else {
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    }
  }

  Widget _errorPlaceholder() => Center(
    child: Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, color: Colors.red),
    ),
  );
}
