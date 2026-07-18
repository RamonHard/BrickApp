import 'dart:io';

import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/media_loader.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:brickapp/utils/web_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
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
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[700],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[700],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 32),
          ),
        ),
      );
    }

    // For non-http URLs, check if we're on web
    if (MediaLoader.isWeb) {
      // Web can't access file paths
      return Container(
        color: Colors.grey[700],
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 32),
        ),
      );
    }

    return Image.file(
      File(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[700],
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 32),
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final String videoUrl;
  const _VideoThumbnail({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                BrickVideoPlayer(videoUrl: videoUrl, height: 300),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: const Icon(Icons.videocam, color: Colors.white30, size: 40),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.black, size: 32),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Tap to play', style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
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
  _chewieController?.dispose();
  await _videoPlayerController?.dispose();
  _chewieController = null;
  _videoPlayerController = null;

  if (_isVideo(mediaUrl)) {
    try {
      if (mediaUrl.startsWith('http')) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(mediaUrl),
        );
      } else if (MediaLoader.isWeb) {
        // Can't play local files on web
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Local videos are not supported on web'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      } else {
        _videoPlayerController = VideoPlayerController.file(File(mediaUrl));
      }

      await _videoPlayerController!.initialize();
      
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
      print('Video error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: ${e.toString()}'),
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
  dynamic imageProvider;
  
  if (imageUrl.startsWith('http')) {
    imageProvider = NetworkImage(imageUrl);
  } else if (MediaLoader.isWeb) {
    // On web, show error instead of trying to use File
    return const Center(
      child: Icon(Icons.error_outline, color: Colors.white, size: 50),
    );
  } else {
    imageProvider = FileImage(File(imageUrl));
  }

  return PhotoView(
    imageProvider: imageProvider as ImageProvider,
    minScale: PhotoViewComputedScale.contained,
    maxScale: PhotoViewComputedScale.covered * 2,
    backgroundDecoration: const BoxDecoration(color: Colors.black),
    loadingBuilder: (context, event) => const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
    errorBuilder: (context, error, stackTrace) => const Center(
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
