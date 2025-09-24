import 'dart:io';

import 'package:flutter/material.dart';

Widget buildImage(String url, {double? width, double? height, BoxFit? fit}) {
  if (_isVideo(url)) {
    // Return a video thumbnail with play icon
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Stack(
        alignment: Alignment.center,
        children: [
          // You might want to use a video thumbnail package here
          // For now, just show a placeholder with play icon
          Icon(Icons.videocam, size: 30, color: Colors.grey[600]),
          Icon(Icons.play_circle_outline, size: 40, color: Colors.white),
        ],
      ),
    );
  } else {
    // Regular image handling
    return url.startsWith('http')
        ? Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => Icon(Icons.broken_image),
        )
        : Image.file(
          File(url),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => Icon(Icons.broken_image),
        );
  }
}

bool _isVideo(String url) {
  final ext = url.split('.').last.toLowerCase();
  return ['mp4', 'mov', 'avi', 'wmv', 'flv', 'webm'].contains(ext);
}
