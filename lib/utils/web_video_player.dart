import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Web implementation
import 'web_video_player_web.dart' if (dart.library.io) 'web_video_player_stub.dart';

class BrickVideoPlayer extends StatelessWidget {
  final String? videoUrl;
  final double height;
  final bool autoPlay;

  const BrickVideoPlayer({
    super.key,
    required this.videoUrl,
    this.height = 220,
    this.autoPlay = false,
  });

  @override
  Widget build(BuildContext context) {
    if (videoUrl == null || videoUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    if (kIsWeb) {
      return WebVideoPlayerWidget(
        videoUrl: videoUrl!,
        height: height,
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.black87,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, color: Colors.white54, size: 40),
          SizedBox(height: 8),
          Text('No video available', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}
