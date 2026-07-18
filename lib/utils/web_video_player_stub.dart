import 'package:flutter/material.dart';

class WebVideoPlayerWidget extends StatelessWidget {
  final String videoUrl;
  final double height;

  const WebVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.black87,
      child: const Center(
        child: Icon(Icons.play_circle_outline, color: Colors.white, size: 48),
      ),
    );
  }
}
