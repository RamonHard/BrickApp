import 'dart:io';

import 'package:brickapp/pages/client_pages/full_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class GalleryView extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const GalleryView({
    super.key,
    required this.mediaUrls,
    this.initialIndex = 0,
  });

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  // Helper method to check if a file is a video
  bool _isVideo(String url) {
    final ext = url.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'wmv', 'flv', 'webm'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaUrls.isEmpty) {
      return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text('Gallery')),
        body: const Center(child: Text('No media available')),
      );
    }

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Gallery')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: widget.mediaUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => FullScreenGallery(
                        mediaUrls: widget.mediaUrls,
                        initialIndex: index,
                      ),
                ),
              );
            },
            child: buildGalleryItem(widget.mediaUrls[index]),
          );
        },
      ),
    );
  }

  Widget buildGalleryItem(String mediaUrl) {
    final isVideo = _isVideo(mediaUrl);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media content
          isVideo
              ? _VideoThumbnail(videoUrl: mediaUrl)
              : _ImageThumbnail(imageUrl: mediaUrl),

          // Video indicator
          if (isVideo)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final String imageUrl;

  const _ImageThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child:
          imageUrl.startsWith('http')
              ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              )
              : Image.file(
                File(imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  final String videoUrl;

  const _VideoThumbnail({required this.videoUrl});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      if (widget.videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.network(widget.videoUrl);
      } else {
        _controller = VideoPlayerController.file(File(widget.videoUrl));
      }

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      // Set the video to the first frame
      _controller!.seekTo(Duration.zero);
      _controller!.setVolume(0); // Mute for thumbnails
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: Icon(Icons.videocam, size: 40, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoPlayer(_controller!),
          Container(color: Colors.black.withOpacity(0.3)),
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }
}
