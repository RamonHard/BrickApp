import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenGallery extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.mediaUrls,
    required this.initialIndex,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;

  // Helper method to check if a file is a video
  bool _isVideo(String url) {
    if (url.isEmpty) return false;
    final ext = url.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'wmv', 'flv', 'webm', 'm4v'].contains(ext);
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize video if the initial index is a video
    if (_isVideo(widget.mediaUrls[_currentIndex])) {
      _initializeVideoController(widget.mediaUrls[_currentIndex]);
    }
  }

  Future<void> _initializeVideoController(String videoUrl) async {
    // Dispose of any existing controller
    await _videoController?.dispose();

    setState(() {
      _isVideoInitialized = false;
      _isVideoPlaying = false;
      _hasVideoError = false;
    });

    try {
      if (videoUrl.startsWith('http')) {
        _videoController = VideoPlayerController.network(videoUrl);
      } else {
        _videoController = VideoPlayerController.file(File(videoUrl));
      }

      await _videoController!.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }

      _videoController!.addListener(() {
        if (mounted) {
          setState(() {
            _isVideoPlaying = _videoController!.value.isPlaying;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
          _hasVideoError = true;
        });
      }
      print('Error initializing video: $e');
    }
  }

  void _toggleVideoPlayPause() {
    if (_videoController != null && _isVideoInitialized) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    } else if (_hasVideoError) {
      // Try to reinitialize if there was an error
      _initializeVideoController(widget.mediaUrls[_currentIndex]);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isVideo(widget.mediaUrls[_currentIndex]))
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: _toggleVideoPlayPause,
            ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaUrls.length,
            onPageChanged: (index) async {
              // Dispose of current video controller if we're switching away from a video
              if (_isVideo(widget.mediaUrls[_currentIndex])) {
                await _videoController?.dispose();
                _videoController = null;
              }

              setState(() {
                _currentIndex = index;
                _hasVideoError = false;
              });

              // Initialize new video controller if we're switching to a video
              if (_isVideo(widget.mediaUrls[_currentIndex])) {
                await _initializeVideoController(
                  widget.mediaUrls[_currentIndex],
                );
              }
            },
            itemBuilder: (context, index) {
              final mediaUrl = widget.mediaUrls[index];
              return _isVideo(mediaUrl)
                  ? _FullScreenVideo(
                    videoUrl: mediaUrl,
                    controller: _videoController,
                    isInitialized: _isVideoInitialized,
                    isPlaying: _isVideoPlaying,
                    hasError: _hasVideoError,
                    onTap: _toggleVideoPlayPause,
                    onRetry: () => _initializeVideoController(mediaUrl),
                  )
                  : _FullScreenImage(imageUrl: mediaUrl);
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.mediaUrls.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: Center(
        child:
            imageUrl.startsWith('http')
                ? Image.network(
                  imageUrl,
                  errorBuilder:
                      (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.white,
                      ),
                )
                : Image.file(
                  File(imageUrl),
                  errorBuilder:
                      (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.white,
                      ),
                ),
      ),
    );
  }
}

class _FullScreenVideo extends StatelessWidget {
  final String videoUrl;
  final VideoPlayerController? controller;
  final bool isInitialized;
  final bool isPlaying;
  final bool hasError;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  const _FullScreenVideo({
    required this.videoUrl,
    required this.controller,
    required this.isInitialized,
    required this.isPlaying,
    required this.hasError,
    required this.onTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isInitialized && controller != null)
            AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: VideoPlayer(controller!),
            )
          else if (hasError)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Unable to play video',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          if (!isPlaying && isInitialized)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
            ),
        ],
      ),
    );
  }
}
