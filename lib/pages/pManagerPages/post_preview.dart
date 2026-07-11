import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/pManagerPages/edit_post.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'dart:typed_data';

class PostPreviewPage extends StatefulWidget {
  final PropertyModel property;

  const PostPreviewPage({super.key, required this.property});

  @override
  State<PostPreviewPage> createState() => _PostPreviewPageState();
}

class _PostPreviewPageState extends State<PostPreviewPage> {
  late PageController _pageController;
  int _currentPage = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  List<String> _allMedia = [];
  List<String> _imageUrls = [];
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadMedia();
  }

  void _loadMedia() {
    // Load all images from the property
    _imageUrls = [];
    
    // Add main image if exists
    if (widget.property.productIMG != null && widget.property.productIMG!.isNotEmpty) {
      _imageUrls.add(_getFullImageUrl(widget.property.productIMG!));
    }
    
    // Add inside views
    if (widget.property.insideViews != null && widget.property.insideViews!.isNotEmpty) {
      for (final url in widget.property.insideViews!) {
        if (url.isNotEmpty) {
          _imageUrls.add(_getFullImageUrl(url));
        }
      }
    }
    
    // Add image URLs
    if (widget.property.imageUrls != null && widget.property.imageUrls!.isNotEmpty) {
      for (final url in widget.property.imageUrls!) {
        if (url.isNotEmpty && !_imageUrls.contains(_getFullImageUrl(url))) {
          _imageUrls.add(_getFullImageUrl(url));
        }
      }
    }
    
    // If no images found, add placeholder
    if (_imageUrls.isEmpty) {
      _imageUrls.add('');
    }
    
    // Load video if exists
    if (widget.property.videoPath != null && widget.property.videoPath!.isNotEmpty) {
      _videoUrl = _getFullImageUrl(widget.property.videoPath!);
      _initializeVideo(_videoUrl!);
    }
    
    // Build all media list for the carousel
    _allMedia = List.from(_imageUrls);
    if (_videoUrl != null) {
      _allMedia.add(_videoUrl!);
    }
    
    setState(() {});
  }

  String _getFullImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    String baseUrl = AppUrls.baseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    return url.startsWith('/') ? '$baseUrl$url' : '$baseUrl/$url';
  }

  void _initializeVideo(String url) async {
    _videoController = VideoPlayerController.network(url);
    await _videoController!.initialize();
    setState(() {
      _isVideoInitialized = true;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0", "en_US");
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final isSmallScreen = MediaQuery.of(context).size.width < 500;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Property Preview',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPost(property: widget.property),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Carousel (Images + Video)
            _buildMediaCarousel(isSmallScreen),
            const SizedBox(height: 16),

            // Media indicators (dots)
            if (_allMedia.length > 1) _buildMediaIndicators(),
            const SizedBox(height: 16),

            // Property Status Badge
            _buildStatusBadge(),
            const SizedBox(height: 16),

            // Property Title and Price
            _buildTitleAndPrice(currencyFormatter, isSmallScreen),
            const SizedBox(height: 12),

            // Location
            _buildLocationSection(),
            const SizedBox(height: 16),

            // Listing Type
            _buildListingTypeSection(),
            const SizedBox(height: 20),

            // Basic Information
            _buildBasicInfoSection(isSmallScreen),
            const SizedBox(height: 20),

            // Amenities
            if (widget.property.amenities != null && widget.property.amenities!.isNotEmpty)
              _buildAmenitiesSection(isSmallScreen),

            // Description
            _buildDescriptionSection(),
            const SizedBox(height: 20),

            // Price Details
            _buildPriceDetails(currencyFormatter),
            const SizedBox(height: 20),

            // Media Summary
            if (_allMedia.length > 1 || _videoUrl != null || widget.property.rulesDocumentPath != null)
              _buildMediaSummary(isSmallScreen),
            const SizedBox(height: 20),

            // Document Section
            if (widget.property.rulesDocumentPath != null && widget.property.rulesDocumentPath!.isNotEmpty)
              _buildDocumentSection(isSmallScreen),
            const SizedBox(height: 20),

            // Upload Information
            _buildUploadInfo(dateFormatter, isSmallScreen),
            const SizedBox(height: 20),

            // Action Button
            _buildActionButton(context, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCarousel(bool isSmallScreen) {
    if (_allMedia.isEmpty) {
      return Container(
        height: isSmallScreen ? 200 : 250,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: isSmallScreen ? 40 : 60,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    return Container(
      height: isSmallScreen ? 250 : 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: _allMedia.length,
          itemBuilder: (context, index) {
            final media = _allMedia[index];
            final isVideo = media == _videoUrl;
            
            if (isVideo && _videoController != null && _isVideoInitialized) {
              return Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (_videoController!.value.isPlaying) {
                              _videoController!.pause();
                            } else {
                              _videoController!.play();
                            }
                          });
                        },
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Video',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            
            // Image
            if (media.isNotEmpty) {
              return Stack(
                children: [
                  Image.network(
                    media,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: isSmallScreen ? 40 : 60,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                  if (index == 0 && _imageUrls.length > 1)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Main Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 9 : 11,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
            
            // Placeholder
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: isSmallScreen ? 40 : 60,
                  color: Colors.grey[400],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMediaIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _allMedia.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? AppColors.iconColor
                : Colors.grey[300],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.property.isActive ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.property.isActive ? Colors.green[100]! : Colors.orange[100]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.property.isActive ? Icons.check_circle : Icons.pending,
            size: 14,
            color: widget.property.isActive ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            widget.property.isActive ? 'Active Listing' : 'Pending Review',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.property.isActive ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndPrice(NumberFormat currencyFormatter, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.property.propertyType ?? 'Property',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 16 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextColor,
                ),
              ),
              if (widget.property.propertyType != null &&
                  widget.property.propertyType!.isNotEmpty)
                Text(
                  widget.property.propertyType!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.property.isRent && widget.property.price != null)
              Text(
                'UGX ${currencyFormatter.format(widget.property.price)}/month',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
            if (widget.property.isSale && widget.property.enteredSalePrice != null)
              Text(
                'UGX ${currencyFormatter.format(widget.property.enteredSalePrice)}',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            if (widget.property.discount != null && widget.property.discount! > 0)
              Text(
                'UGX ${currencyFormatter.format(widget.property.discount)} discount',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.property.location ?? 'Location not specified',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildListingTypeSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (widget.property.isRent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  'For Rent',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                if (widget.property.package != null)
                  Text(
                    ' • ${widget.property.package}',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
              ],
            ),
          ),
        if (widget.property.isSale)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart, size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'For Sale',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                if (widget.property.saleConditions != null &&
                    widget.property.saleConditions!.isNotEmpty)
                  Text(
                    ' • ${widget.property.saleConditions}',
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                  ),
              ],
            ),
          ),
        if (widget.property.isRent && widget.property.isSale)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange[100]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.business_center, size: 14, color: Colors.orange),
                const SizedBox(width: 6),
                Text(
                  'Both Rent & Sale',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfoSection(bool isSmallScreen) {
    final items = <Widget>[];
    
    if (widget.property.bedrooms != null && widget.property.bedrooms! > 0) {
      items.add(_buildInfoItem(Icons.bed, '${widget.property.bedrooms} Bedrooms'));
    }
    if (widget.property.baths != null && widget.property.baths! > 0) {
      items.add(_buildInfoItem(Icons.bathroom, '${widget.property.baths} Bathrooms'));
    }
    if (widget.property.sqft != null && widget.property.sqft! > 0) {
      items.add(_buildInfoItem(Icons.square_foot, '${widget.property.sqft} sq ft'));
    }
    if (widget.property.units != null && widget.property.units! > 0) {
      items.add(_buildInfoItem(Icons.apartment, '${widget.property.units} Units'));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Details',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: items,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildAmenitiesSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.property.amenities!.map((amenity) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  amenity,
                  style: TextStyle(fontSize: isSmallScreen ? 11 : 12, color: Colors.grey[700]),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.property.description ?? 'No description provided',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.property.isRent)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceRow('Monthly Rent', widget.property.price, currencyFormatter),
                if (widget.property.discount != null && widget.property.discount! > 0)
                  _buildPriceRow('Discount', widget.property.discount, currencyFormatter),
                if (widget.property.commission != null && widget.property.commission! > 0)
                  _buildPriceRow('Commission', widget.property.commission, currencyFormatter),
              ],
            ),
          if (widget.property.isRent && widget.property.isSale) const Divider(),
          if (widget.property.isSale)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceRow('Sale Price', widget.property.enteredSalePrice, currencyFormatter),
                if (widget.property.saleConditions != null &&
                    widget.property.saleConditions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Conditions: ${widget.property.saleConditions}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double? amount, NumberFormat currencyFormatter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            amount != null ? 'UGX ${currencyFormatter.format(amount)}' : 'N/A',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: label.contains('Discount') ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSummary(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Media Summary',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMediaChip(
                Icons.image,
                '${_imageUrls.length} Images',
                Colors.blue,
              ),
              if (_videoUrl != null)
                _buildMediaChip(
                  Icons.videocam,
                  '1 Video',
                  Colors.orange,
                ),
              if (widget.property.rulesDocumentPath != null && 
                  widget.property.rulesDocumentPath!.isNotEmpty)
                _buildMediaChip(
                  Icons.description,
                  '1 Document',
                  Colors.green,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.description,
              color: Colors.green,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rules & Regulations Document',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextColor,
                  ),
                ),
                Text(
                  widget.property.rulesDocumentPath!.split('/').last,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Add document preview functionality
              _showSnackBar('Document preview coming soon');
            },
            icon: const Icon(Icons.visibility, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadInfo(DateFormat dateFormatter, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Information',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.property.uploaderName != null)
            _buildInfoRow('Uploaded by', widget.property.uploaderName!),
          if (widget.property.dateCreated != null)
            _buildInfoRow(
              'Date Posted',
              dateFormatter.format(widget.property.dateCreated!),
            ),
          if (widget.property.uploaderPhoneNumber != null)
            _buildInfoRow('Contact', widget.property.uploaderPhoneNumber!.toString()),
          if (widget.property.pendingReason != null &&
              widget.property.pendingReason!.isNotEmpty)
            _buildInfoRow('Pending Reason', widget.property.pendingReason!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPost(property: widget.property),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.iconColor,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Edit This Post',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}