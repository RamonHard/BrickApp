import 'dart:io';
import 'package:flutter/material.dart';

const String _baseUrl =
    'http://192.168.1.12:3000'; // Change to your backend URL

// Converts a backend path to a full URL
String toFullUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  if (path.startsWith('/')) return '$_baseUrl$path';
  return '$_baseUrl/$path';
}

Widget buildImage(String? url, {double? width, double? height, BoxFit? fit}) {
  if (url == null || url.isEmpty) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.home, color: Colors.grey[500]),
    );
  }

  final fullUrl = toFullUrl(url);

  if (_isVideo(fullUrl)) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.videocam, size: 30, color: Colors.grey[600]),
          Icon(Icons.play_circle_outline, size: 40, color: Colors.white),
        ],
      ),
    );
  }

  // Network image
  if (fullUrl.startsWith('http')) {
    return Image.network(
      fullUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder:
          (_, __, ___) => Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: Colors.grey[500]),
          ),
    );
  }

  // Local file
  return Image.file(
    File(fullUrl),
    width: width,
    height: height,
    fit: fit,
    errorBuilder:
        (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, color: Colors.grey[500]),
        ),
  );
}

bool _isVideo(String url) {
  final ext = url.split('.').last.toLowerCase();
  return ['mp4', 'mov', 'avi', 'wmv', 'flv', 'webm'].contains(ext);
}
