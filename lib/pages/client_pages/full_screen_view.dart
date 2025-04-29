import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../utils/app_colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenView extends StatelessWidget {
  const FullScreenView({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.iconColor,
          ),
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
        child: Container(
          width: width,
          height: height,
          child: PhotoViewGallery.builder(
            scrollPhysics: BouncingScrollPhysics(),
            itemCount: imageUrl.length,
            backgroundDecoration: BoxDecoration(color: Colors.black),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(
                  imageUrl,
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            pageController: PageController(),
            scrollDirection: Axis.horizontal,
          ),
          // Hero(
          //   tag: imageUrl,
          //   child: Image.network(
          //     imageUrl,
          //     fit: BoxFit.cover,
          //   ),
          // ),
        ),
      ),
    );
  }
}
