import 'dart:io';
import 'package:brickapp/pages/client_pages/full_screen_view.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

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
  bool _isVideo(String url) {
    final ext = url.split('.').last.toLowerCase();
    return [
      'mp4',
      'mov',
      'avi',
      'wmv',
      'flv',
      'webm',
      'mkv',
      '3gp',
    ].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaUrls.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor,
          centerTitle: true,
          title: Text(
            'Gallery',
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: AppColors.iconColor),
        ),
        body: Container(
          color: AppColors.backgroundColor,
          child: const Center(
            child: Text(
              'No media available',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          'Gallery',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[900],
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
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
      ),
    );
  }

  Widget buildGalleryItem(String mediaUrl) {
    final isVideo = _isVideo(mediaUrl);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[800],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            isVideo
                ? _VideoThumbnail(videoUrl: mediaUrl)
                : _ImageThumbnail(imageUrl: mediaUrl),
            if (isVideo)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
            if (isVideo)
              const Center(
                child: Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 36,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black87)],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final String imageUrl;

  const _ImageThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return imageUrl.startsWith('http')
        ? CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                color: Colors.grey[700],
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => Container(
                color: Colors.grey[700],
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 32,
                  ),
                ),
              ),
        )
        : Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Container(
                color: Colors.grey[700],
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 32,
                  ),
                ),
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
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      if (widget.videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      } else {
        _controller = VideoPlayerController.file(File(widget.videoUrl));
      }

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isError = false;
        });
        _controller!.seekTo(Duration.zero);
        _controller!.setVolume(0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _isError = true;
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
    if (_isError || !_isInitialized) {
      return Container(
        color: Colors.grey[700],
        child: Center(
          child: Icon(
            _isError ? Icons.error_outline : Icons.videocam,
            color: Colors.white54,
            size: 32,
          ),
        ),
      );
    }

    return VideoPlayer(_controller!);
  }
}

// Full screen gallery view
class FullScreenGallery extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.mediaUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;

  bool _isVideo(String url) {
    final ext = url.split('.').last.toLowerCase();
    return [
      'mp4',
      'mov',
      'avi',
      'wmv',
      'flv',
      'webm',
      'mkv',
      '3gp',
    ].contains(ext);
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeVideoIfNeeded(widget.mediaUrls[widget.initialIndex]);
  }

  Future<void> _initializeVideoIfNeeded(String mediaUrl) async {
    // Dispose previous controllers
    _chewieController?.dispose();
    await _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;

    if (_isVideo(mediaUrl)) {
      try {
        // Initialize video controller with proper URI handling
        if (mediaUrl.startsWith('http')) {
          print('Loading video from network: $mediaUrl');
          _videoPlayerController = VideoPlayerController.networkUrl(
            Uri.parse(mediaUrl),
          );
        } else {
          print('Loading video from file: $mediaUrl');
          _videoPlayerController = VideoPlayerController.file(File(mediaUrl));
        }

        await _videoPlayerController!.initialize();

        // Create Chewie controller
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: false,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.blue,
            handleColor: Colors.blue,
            backgroundColor: Colors.grey.shade600,
            bufferedColor: Colors.grey.shade400,
          ),
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          autoInitialize: true,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                'Error: $errorMessage',
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );

        if (mounted) setState(() {});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading video: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBG,
      appBar: AppBar(
        backgroundColor: AppColors.whiteBG,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.mediaUrls.length}',
          style: TextStyle(color: AppColors.textColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.mediaUrls.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  _initializeVideoIfNeeded(widget.mediaUrls[index]);
                },
                itemBuilder: (context, index) {
                  final mediaUrl = widget.mediaUrls[index];
                  final isVideo = _isVideo(mediaUrl);

                  return Container(
                    color: Colors.black,
                    child: Center(
                      child:
                          isVideo
                              ? _buildVideoPlayer(mediaUrl, index)
                              : _buildImageView(mediaUrl),
                    ),
                  );
                },
              ),
            ),
            _buildBottomIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String mediaUrl, int index) {
    // Only show video player for current page
    if (index != _currentIndex) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.videocam, color: Colors.white54, size: 50),
        ),
      );
    }

    // Show loading while initializing
    if (_chewieController == null || _videoPlayerController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // THIS IS THE FIX: Use Chewie widget instead of VideoPlayer
    return Center(
      child: AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }

  Widget _buildImageView(String imageUrl) {
    return PhotoView(
      imageProvider:
          imageUrl.startsWith('http')
              ? NetworkImage(imageUrl)
              : FileImage(File(imageUrl)) as ImageProvider,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder:
          (context, event) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      errorBuilder:
          (context, error, stackTrace) => const Center(
            child: Icon(Icons.error_outline, color: Colors.white, size: 50),
          ),
    );
  }

  Widget _buildBottomIndicator() {
    return Container(
      height: 80,
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.mediaUrls.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          final mediaUrl = widget.mediaUrls[index];
          final isVideo = _isVideo(mediaUrl);

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    isVideo
                        ? _VideoThumbnail(videoUrl: mediaUrl)
                        : _ImageThumbnail(imageUrl: mediaUrl),
                    if (isVideo)
                      const Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
