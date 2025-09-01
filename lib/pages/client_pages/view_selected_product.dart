import 'dart:io';

import 'package:brickapp/models/product_model.dart';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/notifiers/fav_item_notofier.dart';
import 'package:brickapp/pages/client_pages/full_screen_view.dart';
import 'package:brickapp/pages/client_pages/gallery_view.dart';
import 'package:brickapp/providers/discount_provider.dart';
import 'package:brickapp/providers/product_providers.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:brickapp/utils/discount_function.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ViewSelectedProduct extends ConsumerWidget {
  const ViewSelectedProduct({super.key, required this.selectedProduct});
  final PropertyModel selectedProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasShownDialog = ref.watch(discountDialogShownProvider);

    if (!hasShownDialog) {
      Future.microtask(() {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("🎉 Special Offer"),
                content: Text.rich(
                  TextSpan(
                    style: GoogleFonts.oxygen(
                      color: AppColors.darkTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      const TextSpan(
                        text: "Get 8% discount on your first payment!\n\n",
                      ),
                      const TextSpan(text: "Secure the property now at "),
                      TextSpan(
                        text:
                            "UGX ${(selectedProduct.price - selectedProduct.discount).toStringAsFixed(2)}\n\n",
                        style: GoogleFonts.oxygen(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text:
                            "You can cancel the transaction at any time after visiting the property and change your mind.\n\n"
                            "Ensure to complete the transaction once you have visited the property to get a receipt.",
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );

        // Mark dialog as shown
        ref.read(discountDialogShownProvider.notifier).state = true;
      });
    }
    final width = MediaQuery.of(context).size.width;
    final isFavorite = ref.watch(
      favoriteItemListProvider.select(
        (favorites) => favorites.contains(selectedProduct),
      ),
    );
    final favoriteHouseListNotifier = ref.read(
      favoriteItemListProvider.notifier,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Property Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                buildImage(
                  selectedProduct.productIMG,
                  width: width,
                  height: 250,
                ),

                Positioned(
                  right: 10,
                  top: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () {
                        if (isFavorite) {
                          favoriteHouseListNotifier.removeFromFavorites(
                            selectedProduct,
                          );
                        } else {
                          favoriteHouseListNotifier.addToFavorites(
                            selectedProduct,
                          );
                        }
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    height: 35,
                    width: 75,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.house, color: Colors.white),
                        Text(
                          "${selectedProduct.units}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.whiteTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            selectedProduct.isActive
                ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(child: Container()),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            MainNavigation.navigateToRoute(
                              MainNavigation.paymentMethodRoute,
                              data: selectedProduct,
                            );
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text('Book'),
                        ),
                      ),
                    ],
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "${selectedProduct.pendingReason}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedProduct.propertyType,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "UGX ${selectedProduct.price - selectedProduct.discount}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 255, 8),
                        ),
                      ),
                      Text(
                        "UGX ${selectedProduct.price}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          textStyle: TextStyle(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    selectedProduct.location,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Text('${selectedProduct.starRating} '),
                  Text(
                    '(${selectedProduct.reviews} reviews)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFeatureIcon(
                    Icons.bed,
                    '${selectedProduct.bedrooms} Beds',
                  ),
                  _buildFeatureIcon(Icons.weekend, 'Living Room'),
                  _buildFeatureIcon(Icons.park, 'Compound'),
                  _buildFeatureIcon(Icons.local_parking, 'Parking'),
                ],
              ),
            ),

            // Replace your featured images section with this:
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Featured Images',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 8),

            // Featured Images
            selectedProduct.insideViews.isNotEmpty
                ? SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedProduct.insideViews.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final imgPath = selectedProduct.insideViews[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => FullScreenGallery(
                                    imageUrls: selectedProduct.insideViews,
                                    initialIndex: i,
                                  ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: buildImage(
                            imgPath,
                            width: 120,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "No featured images available",
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

            // Show "View All Photos" button only if there are inside views
            (selectedProduct.insideViews.isNotEmpty)
                ? TextButton(
                  onPressed: () {
                    // Debug print to verify the data
                    print("Inside views: ${selectedProduct.insideViews}");
                    print(
                      "Number of images: ${selectedProduct.insideViews.length}",
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => GalleryView(
                              imageUrls: selectedProduct.insideViews,
                            ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined),
                      SizedBox(width: 4),
                      Text(
                        'View All Photos (${selectedProduct.insideViews.length})',
                      ),
                    ],
                  ),
                )
                : SizedBox.shrink(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Description',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextColor,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(selectedProduct.description),
            ),

            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      backgroundImage: NetworkImage(
                        selectedProduct.uploaderIMG,
                      ),
                    ),
                    title: Text(
                      selectedProduct.uploaderName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                    subtitle: Text(
                      'Property Manager',
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    MainNavigation.navigateToRoute(
                      MainNavigation.viewMoreProducts,
                      data: selectedProduct,
                    );
                  },
                  padding: EdgeInsets.all(8.0),
                  color: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'View More',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTextColor,
                    ),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.black),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget buildImage(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (path.isEmpty) {
      return _errorPlaceholder(width, height);
    }

    try {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _errorPlaceholder(width, height),
        );
      } else {
        return Image.file(
          File(path),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _errorPlaceholder(width, height),
        );
      }
    } catch (e) {
      return _errorPlaceholder(width, height);
    }
  }

  Widget _errorPlaceholder(double? width, double? height) => Container(
    width: width,
    height: height,
    color: Colors.grey.shade300,
    child: const Icon(Icons.broken_image, color: Colors.red),
  );
}
