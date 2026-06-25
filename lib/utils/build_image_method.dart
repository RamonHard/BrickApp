import 'package:flutter/material.dart';
import 'package:brickapp/utils/urls.dart';

// Converts a backend path to a full URL using the app's baseUrl
String toFullUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  
  // Clean baseUrl - remove trailing slash
  final base = AppUrls.baseUrl.endsWith('/')
      ? AppUrls.baseUrl.substring(0, AppUrls.baseUrl.length - 1)
      : AppUrls.baseUrl;

  if (path.startsWith('/')) return '$base$path';
  return '$base/$path';
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
          const Icon(Icons.play_circle_outline, size: 40, color: Colors.white),
        ],
      ),
    );
  }

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
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    },
    errorBuilder: (_, __, ___) => Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.broken_image, color: Colors.grey[500]),
    ),
  );
}

bool _isVideo(String url) {
  final lower = url.toLowerCase().split('?').first; // ignore query params
  final ext = lower.split('.').last;
  return ['mp4', 'mov', 'avi', 'wmv', 'flv', 'webm'].contains(ext);
}
