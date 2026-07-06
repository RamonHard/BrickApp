import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Web-only
import 'video_player_web.dart'
    if (dart.library.io) 'video_player_mobile.dart';

class BrickVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final double? height;

  const BrickVideoPlayer({
    super.key,
    required this.videoUrl,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebVideoPlayer(videoUrl: videoUrl, height: height ?? 220);
    }
    return MobileVideoPlayer(videoUrl: videoUrl, height: height ?? 220);
  }
}