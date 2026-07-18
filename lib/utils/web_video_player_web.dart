// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
// ignore: avoid_web_libraries_in_flutter  
import 'dart:html' as html;
import 'package:flutter/material.dart';

class WebVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final double height;

  const WebVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.height,
  });

  @override
  State<WebVideoPlayerWidget> createState() => _WebVideoPlayerWidgetState();
}

class _WebVideoPlayerWidgetState extends State<WebVideoPlayerWidget> {
  late String _viewId;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    _viewId = 'brick-video-${widget.videoUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    _registerView();
  }

  void _registerView() {
    if (_registered) return;
    _registered = true;
    
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final video = html.VideoElement()
        ..src = widget.videoUrl
        ..controls = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..style.backgroundColor = '#000'
        ..setAttribute('playsinline', 'true')
        ..setAttribute('preload', 'metadata');
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
