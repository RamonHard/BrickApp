// In your gallery_view.dart file
import 'dart:io';

import 'package:brickapp/pages/client_pages/full_screen_view.dart';
import 'package:flutter/material.dart';

class GalleryView extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const GalleryView({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gallery')),
        body: const Center(child: Text('No images available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => FullScreenGallery(
                        imageUrls: imageUrls,
                        initialIndex: index,
                      ),
                ),
              );
            },
            child: buildGalleryImage(imageUrls[index]),
          );
        },
      ),
    );
  }

  Widget buildGalleryImage(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child:
          imageUrl.startsWith('http')
              ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              )
              : Image.file(
                File(imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
    );
  }
}
