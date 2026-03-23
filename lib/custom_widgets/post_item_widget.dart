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

  @override
  void initState() {
    super.initState();
    _isPublished =
        widget.property.status == 'active' ||
        widget.property.status == 'pending';
  }

  Future<void> _toggleStatus() async {
    final token = ref.read(userProvider).token;
    if (token == null) return;

    final newStatus = _isPublished ? 'inactive' : 'active';

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            // In _toggleStatus confirm dialog
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

        // Update local provider
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
      builder:
          (context) => AlertDialog(
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
        // Remove from local provider
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PostPreviewPage(property: widget.property),
              ),
            ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.property.propertyType,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
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
                      color:
                          widget.property.status == 'active'
                              ? Colors.green[50]
                              : widget.property.status == 'pending'
                              ? Colors.orange[50]
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            widget.property.status == 'active'
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            widget.property.status == 'active'
                                ? Colors.green
                                : widget.property.status == 'pending'
                                ? Colors.orange
                                : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.property.location.isNotEmpty
                          ? widget.property.location
                          : 'Location not specified',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Price
              if (widget.property.rentPrice != null)
                Text(
                  'UGX ${currencyFormatter.format(widget.property.rentPrice)}/month',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
              if (widget.property.salePrice != null)
                Text(
                  'UGX ${currencyFormatter.format(widget.property.salePrice)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),

              const SizedBox(height: 12),

              // Quick info
              Wrap(
                spacing: 16,
                children: [
                  if (widget.property.bedrooms > 0)
                    _buildInfoChip(
                      Icons.bed,
                      '${widget.property.bedrooms} Beds',
                    ),
                  if (widget.property.baths > 0)
                    _buildInfoChip(
                      Icons.bathroom,
                      '${widget.property.baths} Baths',
                    ),
                  if (widget.property.sqft != null && widget.property.sqft! > 0)
                    _buildInfoChip(
                      Icons.square_foot,
                      '${widget.property.sqft} sqft',
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Actions
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PostPreviewPage(
                                      property: widget.property,
                                    ),
                              ),
                            ),
                        icon: const Icon(Icons.remove_red_eye, size: 16),
                        label: const Text('view'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        EditPost(property: widget.property),
                              ),
                            ),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.iconColor,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 35,
                      child: TextButton(
                        onPressed: _toggleStatus,
                        child: Text(
                          _isPublished ? 'Unpublish' : 'Publish',
                          style: TextStyle(
                            color:
                                _isPublished
                                    ? Colors.orange[700]
                                    : Colors.green[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    SizedBox(
                      height: 35,
                      child: TextButton(
                        onPressed: _deleteProperty,
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}
