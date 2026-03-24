import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/notifiers/fav_item_notofier.dart';
import 'package:brickapp/pages/client_pages/booking-pages/appartment_booking_page.dart';
import 'package:brickapp/pages/client_pages/full_screen_view.dart';
import 'package:brickapp/pages/client_pages/gallery_view.dart'
    hide FullScreenGallery;
import 'package:brickapp/pages/pManagerPages/pdf_pre_view.dart';
import 'package:brickapp/providers/discount_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:brickapp/utils/build_image_method.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ViewSelectedProperty extends ConsumerWidget {
  ViewSelectedProperty({super.key, required this.selectedProduct});
  final PropertyModel selectedProduct;

  final formatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasShownDialog = ref.watch(discountDialogShownProvider);
    final width = MediaQuery.of(context).size.width;
    final isFavorite = ref.watch(
      favoriteItemListProvider.select(
        (favorites) => favorites.contains(selectedProduct),
      ),
    );
    final favoriteHouseListNotifier = ref.read(
      favoriteItemListProvider.notifier,
    );

    // Show discount dialog once
    if (!hasShownDialog) {
      Future.microtask(() {
        _showDiscountDialog(context, ref);
        ref.read(discountDialogShownProvider.notifier).state = true;
      });
    }

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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Hero Image ───────────────────────────────
            Stack(
              children: [
                buildImage(
                  selectedProduct.thumbnailUrl ?? selectedProduct.thumbnail,
                  width: width,
                  height: 250,
                  fit: BoxFit.cover,
                ),

                // Favourite button
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

                // Units badge
                if (selectedProduct.units > 0)
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkBg.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.house,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${selectedProduct.units} Units',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Status badge for pending
                if (selectedProduct.status == 'pending')
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🏗️ Coming Soon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ─── Action Buttons ───────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Pending reason
                  if (selectedProduct.status == 'pending' &&
                      selectedProduct.pendingReason != null &&
                      selectedProduct.pendingReason!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedProduct.pendingReason!,
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Book / Buy buttons
                  Row(
                    children: [
                      // ✅ Rent/Book button
                      if (selectedProduct.listingType == 'rent' ||
                          selectedProduct.listingType == 'rent_and_sale')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PropertyBookingPage(
                                        productModel: selectedProduct,
                                      ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'Book Now',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),

                      if ((selectedProduct.listingType == 'rent' ||
                              selectedProduct.listingType == 'rent_and_sale') &&
                          (selectedProduct.listingType == 'sale' ||
                              selectedProduct.listingType == 'rent_and_sale'))
                        const SizedBox(width: 10),

                      // ✅ Sale/Buy button
                      if (selectedProduct.listingType == 'sale' ||
                          selectedProduct.listingType == 'rent_and_sale')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                () => _showContactDialog(
                                  context,
                                  selectedProduct,
                                ),
                            icon: const Icon(
                              Icons.handshake,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'Buy',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Title + Price ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedProduct.propertyType,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (selectedProduct.numberOfMonths.isNotEmpty &&
                            selectedProduct.numberOfMonths != '0' &&
                            selectedProduct.numberOfMonths != 'null')
                          Text(
                            'Min. ${selectedProduct.numberOfMonths} month${int.tryParse(selectedProduct.numberOfMonths) != null && int.parse(selectedProduct.numberOfMonths) > 1 ? "s" : ""}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (selectedProduct.rentPrice != null &&
                          selectedProduct.rentPrice! > 0)
                        Text(
                          'UGX ${NumberFormat('#,###').format(selectedProduct.rentPrice)}/mo',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      if (selectedProduct.salePrice != null &&
                          selectedProduct.salePrice! > 0)
                        Text(
                          'UGX ${NumberFormat('#,###').format(selectedProduct.salePrice)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Sale Info ────────────────────────────────
            if (selectedProduct.isSale && selectedProduct.enteredSalePrice > 0)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sale Price',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'UGX ${NumberFormat('#,###').format(selectedProduct.enteredSalePrice)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (selectedProduct.saleConditions.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Conditions: ${selectedProduct.saleConditions}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),

            // ─── Location + Rating ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      selectedProduct.location,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 2),
                  Text('${selectedProduct.starRating}'),
                  const SizedBox(width: 4),
                  Text(
                    '(${selectedProduct.reviews.toInt()} reviews)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // ─── Amenities ────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildAmenitiesFromList(selectedProduct),
            ),

            // ─── Featured Media ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Featured Media',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            selectedProduct.insideViews.isNotEmpty ||
                    selectedProduct.videoPath != null
                ? SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _getMediaCount(selectedProduct),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      if (selectedProduct.videoPath != null && i == 0) {
                        return GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FullScreenGallery(
                                        mediaUrls: _getAllMedia(
                                          selectedProduct,
                                        ),
                                        initialIndex: i,
                                      ),
                                ),
                              ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                buildImage(
                                  selectedProduct.videoPath!,
                                  width: 120,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  color: Colors.black.withOpacity(0.3),
                                  width: 120,
                                  height: 100,
                                ),
                                const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        final imgIndex =
                            selectedProduct.videoPath != null ? i - 1 : i;
                        final imgPath = selectedProduct.insideViews[imgIndex];
                        return GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FullScreenGallery(
                                        mediaUrls: _getAllMedia(
                                          selectedProduct,
                                        ),
                                        initialIndex: i,
                                      ),
                                ),
                              ),
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
                      }
                    },
                  ),
                )
                : const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'No featured media available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

            if (selectedProduct.insideViews.isNotEmpty ||
                selectedProduct.videoPath != null)
              TextButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => GalleryView(
                              mediaUrls: _getAllMedia(selectedProduct),
                            ),
                      ),
                    ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_library_outlined),
                    const SizedBox(width: 4),
                    Text('View All Media (${_getMediaCount(selectedProduct)})'),
                  ],
                ),
              ),

            // ─── Description ──────────────────────────────
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
              child: Text(
                selectedProduct.description,
                style: const TextStyle(height: 1.5),
              ),
            ),

            // ─── Rules Document ───────────────────────────
            if (selectedProduct.rulesDocumentPath != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.orangeTextColor),
                  ),
                  leading: const Icon(Icons.description),
                  title: const Text('View Rules & Regulations'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => DocumentPreviewScreen(
                                filePath: selectedProduct.rulesDocumentPath!,
                                title: 'Rules & Regulations',
                              ),
                        ),
                      ),
                ),
              ),

            // ─── Owner Info ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child:
                            selectedProduct.uploaderIMG.isNotEmpty
                                ? null
                                : const Icon(Icons.person),
                        backgroundImage:
                            selectedProduct.uploaderIMG.isNotEmpty
                                ? NetworkImage(selectedProduct.uploaderIMG)
                                : null,
                      ),
                      title: Text(
                        selectedProduct.ownerName ??
                            selectedProduct.uploaderName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                      subtitle: Text(
                        'Property Manager',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MaterialButton(
                      onPressed:
                          () => MainNavigation.navigateToRoute(
                            MainNavigation.viewMoreProducts,
                            data: selectedProduct,
                          ),
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'View More',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── Discount Dialog ──────────────────────────────────────
  void _showDiscountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('🎉 Brick Exclusive Offer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedProduct.rentPrice != null &&
                    selectedProduct.rentPrice! > 0) ...[
                  Text(
                    'UGX ${NumberFormat('#,###').format(selectedProduct.rentPrice)}/month',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                if (selectedProduct.minimumMonths != null &&
                    selectedProduct.minimumMonths! > 0)
                  Text(
                    'Minimum package: ${selectedProduct.minimumMonths} month${selectedProduct.minimumMonths! > 1 ? "s" : ""}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '🎉 '),
                        TextSpan(
                          text: 'Pay through Brick and save!\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Get 8% off our platform fee — exclusive to Brick users!',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                const Text(
                  '💡 You can request a refund within 2 hours of booking if you change your mind.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Got it!'),
              ),
            ],
          ),
    );
  }

  // ─── Contact Dialog for Sale ──────────────────────────────
  void _showContactDialog(BuildContext context, PropertyModel property) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Purchase Enquiry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (property.salePrice != null && property.salePrice! > 0)
                  Text(
                    'UGX ${NumberFormat('#,###').format(property.salePrice)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                if (property.saleConditions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Conditions: ${property.saleConditions}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Contact the property manager:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      property.ownerName ?? property.uploaderName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(property.ownerPhone ?? ''),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────
  int _getMediaCount(PropertyModel product) {
    int count = product.insideViews.length;
    if (product.videoPath != null && product.videoPath!.isNotEmpty) {
      count += 1;
    }
    return count;
  }

  List<String> _getAllMedia(PropertyModel product) {
    List<String> allMedia = [];
    if (product.videoPath != null && product.videoPath!.isNotEmpty) {
      allMedia.add(product.videoPath!);
    }
    allMedia.addAll(product.insideViews);
    return allMedia;
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildAmenitiesFromList(PropertyModel product) {
    final amenityIcons = {
      'Parking': Icons.local_parking,
      'Furnished': Icons.chair,
      'Air Conditioning': Icons.ac_unit,
      'Internet': Icons.wifi,
      'Security': Icons.security,
      'Pet Friendly': Icons.pets,
      'Compound': Icons.grass,
    };

    if (product.amenities.isNotEmpty) {
      List<Widget> amenityWidgets = [];

      if (product.bedrooms > 0) {
        amenityWidgets.add(
          _buildFeatureIcon(Icons.bed, '${product.bedrooms} Beds'),
        );
      }
      if (product.baths > 0) {
        amenityWidgets.add(
          _buildFeatureIcon(Icons.bathroom, '${product.baths} Baths'),
        );
      }
      if (product.sqft != null && product.sqft! > 0) {
        amenityWidgets.add(
          _buildFeatureIcon(Icons.square_foot, '${product.sqft!.toInt()} sqft'),
        );
      }

      for (String amenity in product.amenities) {
        final icon = amenityIcons[amenity] ?? Icons.check_circle;
        amenityWidgets.add(_buildFeatureIcon(icon, amenity));
      }

      return Wrap(spacing: 12, runSpacing: 12, children: amenityWidgets);
    }

    return _buildDynamicAmenities(product);
  }

  Widget _buildDynamicAmenities(PropertyModel product) {
    List<Widget> amenities = [];

    if (product.bedrooms > 0) {
      amenities.add(_buildFeatureIcon(Icons.bed, '${product.bedrooms} Beds'));
    }
    if (product.baths > 0) {
      amenities.add(
        _buildFeatureIcon(Icons.bathroom, '${product.baths} Baths'),
      );
    }
    if (product.sqft != null && product.sqft! > 0) {
      amenities.add(
        _buildFeatureIcon(Icons.square_foot, '${product.sqft!.toInt()} sqft'),
      );
    }
    if (product.hasParking) {
      amenities.add(_buildFeatureIcon(Icons.local_parking, 'Parking'));
    }
    if (product.isFurnished) {
      amenities.add(_buildFeatureIcon(Icons.chair, 'Furnished'));
    }
    if (product.hasAC) {
      amenities.add(_buildFeatureIcon(Icons.ac_unit, 'AC'));
    }
    if (product.hasInternet) {
      amenities.add(_buildFeatureIcon(Icons.wifi, 'Internet'));
    }
    if (product.hasSecurity) {
      amenities.add(_buildFeatureIcon(Icons.security, 'Security'));
    }
    if (product.isPetFriendly) {
      amenities.add(_buildFeatureIcon(Icons.pets, 'Pet Friendly'));
    }
    if (product.hasCompound) {
      amenities.add(_buildFeatureIcon(Icons.grass, 'Compound'));
    }

    if (amenities.isEmpty) {
      return const Text(
        'No amenities listed.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Wrap(spacing: 12, runSpacing: 12, children: amenities);
  }
}
