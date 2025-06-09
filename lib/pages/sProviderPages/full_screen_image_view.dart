import 'dart:io';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImageView extends StatelessWidget {
  const FullScreenImageView({
    super.key,
    required this.imageList,
    required this.imageIndex,
  });
  final List<XFile> imageList;
  final int imageIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
        ),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 10) {
            Navigator.pop(context);
          }
        },
        onTap: () {
          Navigator.pop(context);
        },
        child: PhotoViewGallery.builder(
          itemCount: imageList.length,
          builder: (BuildContext context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: FileImage(File(imageList[index].path)),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
              heroAttributes: PhotoViewHeroAttributes(tag: index),
              tightMode: true,
            );
          },
          scrollPhysics: BouncingScrollPhysics(),
          backgroundDecoration: BoxDecoration(color: Colors.black),
          pageController: PageController(initialPage: imageIndex),
        ),
      ),
    );
  }
}
