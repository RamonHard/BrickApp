import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/notifiers/fav_item_notofier.dart';
import 'package:brickapp/pages/client_pages/gallery_view.dart'
   ;
import 'package:brickapp/providers/discount_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:brickapp/utils/build_image_method.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

class DetailedHouseView extends ConsumerStatefulWidget {
  const DetailedHouseView({super.key, required this.selectedProduct});
  final PropertyModel selectedProduct;

  @override
  ConsumerState<DetailedHouseView> createState() => _DetailedHouseViewState();
}

class _DetailedHouseViewState extends ConsumerState<DetailedHouseView> {
  double _clientDiscountPercent = 5.0;
  int _commissionMonths = 3;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final res = await http.get(
        Uri.parse('${AppUrls.baseUrl}/settings/public'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final settings = List<Map<String, dynamic>>.from(data['settings']);
        for (final s in settings) {
          if (s['key'] == 'client_discount_percent') {
            _clientDiscountPercent =
                double.tryParse(s['value'].toString()) ?? 5.0;
          }
          if (s['key'] == 'commission_months') {
            _commissionMonths = int.tryParse(s['value'].toString()) ?? 3;
          }
        }
      }
    } catch (e) {
      print('❌ Settings error: $e');
    }
    setState(() => _settingsLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final hasShownDialog = ref.watch(discountDialogShownProvider);
    // print('🖼️ Thumbnail: ${selectedProduct.thumbnail}');
    // print('🖼️ Images: ${selectedProduct.images}');
    // print('🖼️ InsideViews: ${selectedProduct.insideViews}');
    // print('🎬 VideoPath: ${selectedProduct.videoPath}');
  if (!hasShownDialog) {
  Future.microtask(() {
    if (_settingsLoaded) {
      _showDiscountDialog(context);
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showDiscountDialog(context);
      });
    }
    ref.read(discountDialogShownProvider.notifier).state = true;
  });
}
    final width = MediaQuery.of(context).size.width;
    final isFavorite = ref.watch(
      favoriteItemListProvider.select(
        (favorites) => favorites.contains(widget.selectedProduct),
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
                  widget.selectedProduct.thumbnail,
                  width: width,
                  height: 250,
                  fit: BoxFit.cover,
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
                            widget.selectedProduct,
                          );
                        } else {
                          favoriteHouseListNotifier.addToFavorites(
                            widget.selectedProduct,
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
                          "${widget.selectedProduct.units}",
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
            widget.selectedProduct.isActive
                ? // ✅ Replace the single Book button
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Row(
    children: [
      if (widget.selectedProduct.listingType == 'rent' ||
          widget.selectedProduct.listingType == 'rent_and_sale')
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.selectedProduct.isActive
                ? () => MainNavigation.navigateToRoute(
                      MainNavigation.paymentMethodRoute,
                      data: widget.selectedProduct,
                    )
                : null,
            icon: const Icon(Icons.calendar_month,
                color: Colors.white, size: 18),
            label: const Text('Book Now',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      if ((widget.selectedProduct.listingType == 'rent' ||
              widget.selectedProduct.listingType == 'rent_and_sale') &&
          (widget.selectedProduct.listingType == 'sale' ||
              widget.selectedProduct.listingType == 'rent_and_sale'))
        const SizedBox(width: 10),
      if (widget.selectedProduct.listingType == 'sale' ||
          widget.selectedProduct.listingType == 'rent_and_sale')
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.handshake,
                color: Colors.white, size: 18),
            label: const Text('Buy',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      // ✅ Show pending reason if not active
      if (!widget.selectedProduct.isActive &&
          widget.selectedProduct.pendingReason != null)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Text(
              widget.selectedProduct.pendingReason!,
              style: TextStyle(color: Colors.orange[800], fontSize: 13),
            ),
          ),
        ),
    ],
  ),
)
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "${widget.selectedProduct.pendingReason}",
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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.selectedProduct.propertyType,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.selectedProduct.numberOfMonths.isNotEmpty &&
                widget.selectedProduct.numberOfMonths != '0' &&
                widget.selectedProduct.numberOfMonths != 'null')
              Text(
                'Min. ${widget.selectedProduct.numberOfMonths} month${int.tryParse(widget.selectedProduct.numberOfMonths) != null && int.parse(widget.selectedProduct.numberOfMonths) > 1 ? "s" : ""}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ✅ Rent price
          if (widget.selectedProduct.rentPrice != null &&
              widget.selectedProduct.rentPrice! > 0)
            Text(
              'UGX ${NumberFormat('#,###').format(widget.selectedProduct.rentPrice)}/mo',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          // ✅ Sale price
          if (widget.selectedProduct.salePrice != null &&
              widget.selectedProduct.salePrice! > 0)
            Text(
              'UGX ${NumberFormat('#,###').format(widget.selectedProduct.salePrice)}',
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

// ✅ Sale conditions box
if (widget.selectedProduct.isSale &&
    widget.selectedProduct.enteredSalePrice > 0)
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
              'UGX ${NumberFormat('#,###').format(widget.selectedProduct.enteredSalePrice)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        if (widget.selectedProduct.saleConditions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Conditions: ${widget.selectedProduct.saleConditions}',
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
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
                    widget.selectedProduct.location,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Text('${widget.selectedProduct.starRating} '),
                  Text(
                    '(${widget.selectedProduct.reviews} reviews)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildAmenitiesFromList(widget.selectedProduct),
            ),

            // Replace your featured images section with this:
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Featured Media', // Changed from 'Featured Images'
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 8),

            // Featured Media (Images & Videos)
            widget.selectedProduct.insideViews.isNotEmpty ||
                    widget.selectedProduct.videoPath != null
                ? SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _getMediaCount(
                      widget.selectedProduct,
                    ), // Updated method
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      // Check if this is a video or image
                      if (widget.selectedProduct.videoPath != null && i == 0) {
                        // Video thumbnail as first item
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => FullScreenGallery(
                                      mediaUrls: _getAllMedia(
                                        widget.selectedProduct,
                                      ), // Updated method
                                      initialIndex: i,
                                    ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                // Video thumbnail with play icon overlay
                                buildImage(
                                  widget.selectedProduct.videoPath!,
                                  width: 120,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  color: Colors.black.withOpacity(0.3),
                                  width: 120,
                                  height: 100,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.videocam,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                Center(
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
                        // Regular image
                        final imgIndex =
                            widget.selectedProduct.videoPath != null
                                ? i - 1
                                : i;
                        final imgPath =
                            widget.selectedProduct.insideViews[imgIndex];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => FullScreenGallery(
                                      mediaUrls: _getAllMedia(
                                        widget.selectedProduct,
                                      ), // Updated method
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
                      }
                    },
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "No featured media available", // Changed text
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

            // Show "View All Media" button only if there are media items
            (widget.selectedProduct.insideViews.isNotEmpty ||
                    widget.selectedProduct.videoPath != null)
                ? TextButton(
                  onPressed: () {
                    // Debug print to verify the data
                    print(
                      "Inside views: ${widget.selectedProduct.insideViews}",
                    );
                    print("Video path: ${widget.selectedProduct.videoPath}");
                    print(
                      "Number of media items: ${_getMediaCount(widget.selectedProduct)}",
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => GalleryView(
                              mediaUrls: _getAllMedia(
                                widget.selectedProduct,
                              ), // Updated method
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
                        'View All Media (${_getMediaCount(widget.selectedProduct)})', // Updated text
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
              child: Text(widget.selectedProduct.description),
            ),

          //   Row(
          //     children: [
          //       Expanded(
          //         child: ListTile(
          //           leading: CircleAvatar(
          //             backgroundColor: Colors.grey[300],
          //             backgroundImage: NetworkImage(
          //               widget.selectedProduct.uploaderIMG,
          //             ),
          //           ),
          //           title: Text(
          //             widget.selectedProduct.uploaderName,
          //             style: GoogleFonts.poppins(
          //               fontSize: 16,
          //               fontWeight: FontWeight.w600,
          //               color: AppColors.darkTextColor,
          //             ),
          //           ),
          //           subtitle: Text(
          //             'Property Manager',
          //             style: GoogleFonts.poppins(
          //               fontSize: 8,
          //               fontWeight: FontWeight.w500,
          //               color: AppColors.lightGrey,
          //             ),
          //           ),
          //         ),
          //       ),
                
          //       SizedBox(width: 5),
          //     ],
          //   ),
          //   SizedBox(height: 20),
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

  Widget _errorPlaceholder(double? width, double? height) => Container(
    width: width,
    height: height,
    color: Colors.grey.shade300,
    child: const Icon(Icons.broken_image, color: Colors.red),
  );

  // Helper method to get total count of media (images + video)
  int _getMediaCount(PropertyModel product) {
    int count = product.insideViews.length;
    if (product.videoPath != null && product.videoPath!.isNotEmpty) {
      count += 1;
    }
    return count;
  }

  // Helper method to combine images and video into a single list
  List<String> _getAllMedia(PropertyModel product) {
    List<String> allMedia = [];

    // Add video first if exists
    if (product.videoPath != null && product.videoPath!.isNotEmpty) {
      allMedia.add(product.videoPath!);
    }

    // Add all images
    allMedia.addAll(product.insideViews);

    return allMedia;
  }

  // Alternative approach: Use the amenities list from PropertyModel if available
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

    // Check if amenities list exists in the model
    if (product.amenities != null && product.amenities!.isNotEmpty) {
      List<Widget> amenityWidgets = [];

      // Add bedrooms first if available
      if (product.bedrooms > 0) {
        amenityWidgets.add(
          _buildFeatureIcon(Icons.bed, '${product.bedrooms} Beds'),
        );
      }

      // Add all amenities from the list
      for (String amenity in product.amenities!) {
        final icon = amenityIcons[amenity] ?? Icons.check_circle;
        amenityWidgets.add(_buildFeatureIcon(icon, amenity));
      }

      return Wrap(spacing: 12, runSpacing: 12, children: amenityWidgets);
    }

    // Fallback: If amenities list doesn't exist, use boolean flags
    return _buildDynamicAmenities(product);
  }

  // Define the missing method
  Widget _buildDynamicAmenities(PropertyModel product) {
    List<Widget> amenities = [];

    if (product.bedrooms > 0) {
      amenities.add(_buildFeatureIcon(Icons.bed, '${product.bedrooms} Beds'));
    }
    if (product.hasParking == true) {
      amenities.add(_buildFeatureIcon(Icons.local_parking, 'Parking'));
    }
    if (product.isFurnished == true) {
      amenities.add(_buildFeatureIcon(Icons.chair, 'Furnished'));
    }
    if (product.hasAC == true) {
      amenities.add(_buildFeatureIcon(Icons.ac_unit, 'Air Conditioning'));
    }
    if (product.hasInternet == true) {
      amenities.add(_buildFeatureIcon(Icons.wifi, 'Internet'));
    }
    if (product.hasSecurity == true) {
      amenities.add(_buildFeatureIcon(Icons.security, 'Security'));
    }
    if (product.isPetFriendly == true) {
      amenities.add(_buildFeatureIcon(Icons.pets, 'Pet Friendly'));
    }
    if (product.hasCompound == true) {
      amenities.add(_buildFeatureIcon(Icons.grass, 'Compound'));
    }

    if (amenities.isEmpty) {
      return Text('No amenities listed.', style: TextStyle(color: Colors.grey));
    }

    return Wrap(spacing: 12, runSpacing: 12, children: amenities);
  }
  
  void _showDiscountDialog(BuildContext context) {
  final rentPrice = widget.selectedProduct.rentPrice ?? 
                    widget.selectedProduct.price;
  final minimumMonths = int.tryParse(
    widget.selectedProduct.numberOfMonths.isEmpty ||
            widget.selectedProduct.numberOfMonths == 'null'
        ? '1'
        : widget.selectedProduct.numberOfMonths) ?? 1;

  final commMonths = minimumMonths < _commissionMonths
      ? minimumMonths
      : _commissionMonths;
  final discountAmount =
      rentPrice * commMonths * (_clientDiscountPercent / 100);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('🎉 Brick Exclusive Offer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Rent price
          if (rentPrice > 0) ...[
            Text(
              'UGX ${_fmt(rentPrice)}/month',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ✅ Minimum months
          if (minimumMonths > 0)
            Text(
              'Minimum: $minimumMonths month${minimumMonths > 1 ? "s" : ""}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

          const SizedBox(height: 12),

          // ✅ Discount info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '🎉 '),
                      const TextSpan(
                        text: 'Pay through Brick and save!\n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      TextSpan(
                        text:
                            'Get ${_clientDiscountPercent.toStringAsFixed(0)}% off on first $commMonths month${commMonths > 1 ? "s" : ""}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                ),
                if (discountAmount > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    'You save: UGX ${_fmt(discountAmount)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ✅ First month price
          if (rentPrice > 0)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'First month you pay:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'UGX ${_fmt(rentPrice * (1 - _clientDiscountPercent / 100))}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),
          const Text(
            '💡 Refund available within 2 hours of booking.',
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

// ✅ Helper formatter
String _fmt(double value) {
  final formatted = value.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return formatted;
}
}
