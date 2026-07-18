import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

class MediaLoader {
  /// Check if running on web platform
  static bool get isWeb => UniversalPlatform.isWeb || kIsWeb;

  /// Get appropriate image provider for the platform
  static dynamic getImageProvider(String url) {
    if (url.startsWith('http')) {
      return NetworkImage(url);
    } else if (isWeb) {
      // On web, we can't use FileImage
      // Return a placeholder or handle differently
      return const AssetImage('assets/placeholder.png');
    } else {
      return FileImage(File(url));
    }
  }

  /// Check if URL can be used on current platform
  static bool isUrlValidForPlatform(String url) {
    if (url.startsWith('http')) return true;
    if (isWeb) return false; // File paths don't work on web
    return File(url).existsSync();
  }
}