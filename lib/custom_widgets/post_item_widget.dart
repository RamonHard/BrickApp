import 'dart:convert';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/pManagerPages/edit_post.dart';
import 'package:brickapp/pages/pManagerPages/post_preview.dart';
import 'package:brickapp/providers/product_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PostListItem extends ConsumerStatefulWidget {
  final PropertyModel property;
  final bool publicState;

  const PostListItem({
    super.key,
    required this.property,
    required this.publicState,
  });

  @override
  ConsumerState<PostListItem> createState() => _PostListItemState();
}

class _PostListItemState extends ConsumerState<PostListItem> {
  bool _isLoading = false;
  late bool _isPublished;
  bool _isImageLoading = true;
  bool _hasImageError = false;

  @override
  void initState() {
    super.initState();
    _isPublished =
        widget.property.status == 'active' ||
        widget.property.status == 'pending';
  }

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    String baseUrl = AppUrls.baseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    return url.startsWith('/') ? '$baseUrl$url' : '$baseUrl/$url';
  }

  String? _getThumbnailUrl() {
    // Try thumbnail first
    if (widget.property.thumbnail != null && widget.property.thumbnail!.isNotEmpty) {
      return _getFullImageUrl(widget.property.thumbnail);
    }
    // Then try productIMG
    if (widget.property.productIMG != null && widget.property.productIMG!.isNotEmpty) {
      return _getFullImageUrl(widget.property.productIMG);
    }
    // Then try first image from imageUrls
    if (widget.property.imageUrls != null && widget.property.imageUrls!.isNotEmpty) {
      return _getFullImageUrl(widget.property.imageUrls!.first);
    }
    // Then try first inside view
    if (widget.property.insideViews != null && widget.property.insideViews!.isNotEmpty) {
      return _getFullImageUrl(widget.property.insideViews!.first);
    }
    return null;
  }

  int _getTotalMediaCount() {
    int count = 0;
    if (widget.property.thumbnail != null && widget.property.thumbnail!.isNotEmpty) count++;
    if (widget.property.productIMG != null && widget.property.productIMG!.isNotEmpty) count++;
    if (widget.property.imageUrls != null) count += widget.property.imageUrls!.length;
    if (widget.property.insideViews != null) count += widget.property.insideViews!.length;
    if (widget.property.videoPath != null && widget.property.videoPath!.isNotEmpty) count++;
    if (widget.property.rulesDocumentPath != null && widget.property.rulesDocumentPath!.isNotEmpty) count++;
    return count;
  }

  bool _hasVideo() {
    return widget.property.videoPath != null && widget.property.videoPath!.isNotEmpty;
  }

  bool _hasDocument() {
    return widget.property.rulesDocumentPath != null && widget.property.rulesDocumentPath!.isNotEmpty;
  }

  Future<void> _toggleStatus() async {
    final token = ref.read(userProvider).token;
    if (token == null) return;

    final newStatus = _isPublished ? 'inactive' : 'active';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isPublished ? 'Hide Property?' : 'Show Property?'),
        content: Text(
          _isPublished
              ? 'This will hide the property from public listings. Clients won\'t see it until you publish again.'
              : 'This will make the property visible to all clients.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPublished ? Colors.orange : Colors.green,
            ),
            child: Text(
              _isPublished ? 'Unpublish' : 'Publish',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.patch(
        Uri.parse(AppUrls.togglePropertyStatus(widget.property.id)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': newStatus}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        setState(() => _isPublished = newStatus == 'active');

        final updated = PropertyModel.fromJson(data['property']);
        ref.read(productProvider.notifier).updateProduct(updated);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isPublished
                  ? 'Property published successfully'
                  : 'Property unpublished',
            ),
            backgroundColor: _isPublished ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProperty() async {
    final token = ref.read(userProvider).token;
    if (token == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property?'),
        content: const Text(
          'This action cannot be undone. The property and all its data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.delete(
        Uri.parse(AppUrls.propertyById(widget.property.id)),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        ref.read(productProvider.notifier).removeProduct(widget.property.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Delete failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final thumbnailUrl = _getThumbnailUrl();
    final totalMedia = _getTotalMediaCount();
    final hasVideo = _hasVideo();
    final hasDocument = _hasDocument();
    final isSmallScreen = MediaQuery.of(context).size.width < 500;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostPreviewPage(property: widget.property),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Main Row: Image + Content ──────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Container(
                    width: isSmallScreen ? 80 : 100,
                    height: isSmallScreen ? 80 : 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                          ? Stack(
                              children: [
                                Image.network(
                                  thumbnailUrl,
                                  width: isSmallScreen ? 80 : 100,
                                  height: isSmallScreen ? 80 : 100,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholder(isSmallScreen);
                                  },
                                ),
                                // Media count badge
                                if (totalMedia > 1)
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.photo_library,
                                            color: Colors.white,
                                            size: 10,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '+${totalMedia - 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                // Video badge
                                if (hasVideo)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.videocam,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                // Document badge
                                if (hasDocument)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.description,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : _buildPlaceholder(isSmallScreen),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.property.propertyType ?? 'Property',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.property.status == 'active'
                                    ? Colors.green[50]
                                    : widget.property.status == 'pending'
                                    ? Colors.orange[50]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: widget.property.status == 'active'
                                      ? Colors.green[100]!
                                      : widget.property.status == 'pending'
                                      ? Colors.orange[100]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                widget.property.status == 'active'
                                    ? 'Active'
                                    : widget.property.status == 'pending'
                                    ? 'Pending'
                                    : 'Inactive',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: widget.property.status == 'active'
                                      ? Colors.green
                                      : widget.property.status == 'pending'
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.property.location.isNotEmpty
                                    ? widget.property.location
                                    : 'Location not specified',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Price
                        Row(
                          children: [
                            if (widget.property.rentPrice != null) ...[
                              Text(
                                'UGX ${currencyFormatter.format(widget.property.rentPrice)}/mo',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue[700],
                                ),
                              ),
                              if (widget.property.salePrice != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  height: 16,
                                  width: 1,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(width: 8),
                              ],
                            ],
                            if (widget.property.salePrice != null)
                              Text(
                                'UGX ${currencyFormatter.format(widget.property.salePrice)}',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green[700],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Quick info chips
                        Wrap(
                          spacing: isSmallScreen ? 8 : 12,
                          runSpacing: 4,
                          children: [
                            if (widget.property.bedrooms != null && widget.property.bedrooms! > 0)
                              _buildInfoChip(
                                Icons.bed,
                                '${widget.property.bedrooms}',
                                isSmallScreen,
                              ),
                            if (widget.property.baths != null && widget.property.baths! > 0)
                              _buildInfoChip(
                                Icons.bathroom,
                                '${widget.property.baths}',
                                isSmallScreen,
                              ),
                            if (widget.property.sqft != null && widget.property.sqft! > 0)
                              _buildInfoChip(
                                Icons.square_foot,
                                '${widget.property.sqft}',
                                isSmallScreen,
                              ),
                            if (widget.property.units != null && widget.property.units! > 0)
                              _buildInfoChip(
                                Icons.apartment,
                                '${widget.property.units}',
                                isSmallScreen,
                              ),
                            // Media count
                            if (totalMedia > 1)
                              _buildInfoChip(
                                Icons.photo_library,
                                '${totalMedia} media',
                                isSmallScreen,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ─── Divider ──────────────────────────────
              const Divider(height: 1),

              const SizedBox(height: 12),

              // ─── Actions ──────────────────────────────
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    // View Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostPreviewPage(
                              property: widget.property,
                            ),
                          ),
                        ),
                        icon: Icon(Icons.remove_red_eye, size: isSmallScreen ? 14 : 16),
                        label: Text(
                          'View',
                          style: TextStyle(fontSize: isSmallScreen ? 11 : 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 4 : 8,
                            vertical: isSmallScreen ? 6 : 10,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Edit Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPost(
                              property: widget.property,
                            ),
                          ),
                        ),
                        icon: Icon(Icons.edit, size: isSmallScreen ? 14 : 16),
                        label: Text(
                          'Edit',
                          style: TextStyle(fontSize: isSmallScreen ? 11 : 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.iconColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 4 : 8,
                            vertical: isSmallScreen ? 6 : 10,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Publish/Unpublish Button
                    SizedBox(
                      height: isSmallScreen ? 30 : 35,
                      child: TextButton(
                        onPressed: _toggleStatus,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 4 : 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _isPublished ? 'Unpublish' : 'Publish',
                          style: TextStyle(
                            color: _isPublished
                                ? Colors.orange[700]
                                : Colors.green[700],
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),

                    // Delete Button
                    SizedBox(
                      height: isSmallScreen ? 30 : 35,
                      child: TextButton(
                        onPressed: _deleteProperty,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 4 : 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 80 : 100,
      height: isSmallScreen ? 80 : 100,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home,
            size: isSmallScreen ? 24 : 32,
            color: Colors.grey[400],
          ),
          if (!isSmallScreen) ...[
            const SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isSmallScreen ? 12 : 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}