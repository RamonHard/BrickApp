import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MobileVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double height;
  const MobileVideoPlayer({super.key, required this.videoUrl, required this.height});

  @override
  State<MobileVideoPlayer> createState() => _MobileVideoPlayerState();
}

class _MobileVideoPlayerState extends State<MobileVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl));
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
      );
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Icon(Icons.error, color: Colors.red)),
      );
    }
    return SizedBox(
      height: widget.height,
      child: Chewie(controller: _chewieController!),
    );
  }
}

class WebVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final double height;
  const WebVideoPlayer({super.key, required this.videoUrl, required this.height});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}