import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/pManagerPages/edit_post.dart';
import 'package:brickapp/pages/pManagerPages/post_preview.dart';
import 'package:brickapp/providers/product_providers.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class MyPostsPage extends ConsumerWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Property Posts',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to AddPost page
              // Navigator.push(context, MaterialPageRoute(
              //   builder: (context) => AddPost(),
              // ));
            },
          ),
        ],
      ),
      body:
          posts.isEmpty
              ? const Center(
                child: Text('No posts found. Create your first property post!'),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final property = posts[index];
                  return PostListItem(property: property);
                },
              ),
    );
  }
}

class PostListItem extends StatelessWidget {
  final PropertyModel property;

  const PostListItem({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0", "en_US");

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to preview page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostPreviewPage(property: property),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with property type and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      property.propertyType ?? 'Property',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          property.isActive
                              ? Colors.green[50]
                              : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            property.isActive
                                ? Colors.green[100]!
                                : Colors.orange[100]!,
                      ),
                    ),
                    child: Text(
                      property.isActive ? 'Active' : 'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: property.isActive ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      property.location ?? 'Location not specified',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Price and Listing Type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Listing type badges
                  Wrap(
                    spacing: 6,
                    children: [
                      if (property.isRent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Rent',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (property.isSale)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Sale',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (property.isRent && property.price != null)
                        Text(
                          'UGX ${currencyFormatter.format(property.price)}/month',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue,
                          ),
                        ),
                      if (property.isSale && property.enteredSalePrice != null)
                        Text(
                          'UGX ${currencyFormatter.format(property.enteredSalePrice)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Quick info
              Wrap(
                spacing: 16,
                children: [
                  if (property.bedrooms != null && property.bedrooms! > 0)
                    _buildInfoChip(Icons.bed, '${property.bedrooms} Beds'),
                  if (property.baths != null && property.baths! > 0)
                    _buildInfoChip(Icons.bathroom, '${property.baths} Baths'),
                  if (property.sqft != null && property.sqft! > 0)
                    _buildInfoChip(Icons.square_foot, '${property.sqft} sqft'),
                ],
              ),

              const SizedBox(height: 12),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to preview
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PostPreviewPage(property: property),
                          ),
                        );
                      },
                      icon: const Icon(Icons.remove_red_eye, size: 16),
                      label: const Text('Preview'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate directly to edit
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPost(property: property),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.iconColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
