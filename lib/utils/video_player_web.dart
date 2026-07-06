// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';

class WebVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double height;
  const WebVideoPlayer({super.key, required this.videoUrl, required this.height});

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'video-${widget.videoUrl.hashCode}';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final video = html.VideoElement()
        ..src = widget.videoUrl
        ..controls = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';
      return video;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}

class MobileVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final double height;
  const MobileVideoPlayer({super.key, required this.videoUrl, required this.height});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}