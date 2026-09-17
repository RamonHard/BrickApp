import 'dart:convert';
import 'package:brickapp/utils/pop_up_dialogues.dart';
import 'package:intl/intl.dart';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/notifiers/fav_item_notofier.dart';
import 'package:brickapp/pages/client_pages/gallery_view.dart';
import 'package:brickapp/providers/discount_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:brickapp/utils/build_image_method.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

class ViewPropertyofOneManager extends ConsumerStatefulWidget {
  const ViewPropertyofOneManager({super.key, required this.selectedProduct});
  final PropertyModel selectedProduct;

  @override
  ConsumerState<ViewPropertyofOneManager> createState() => _ViewPropertyofOneManagerState();
}

class _ViewPropertyofOneManagerState extends ConsumerState<ViewPropertyofOneManager> {
  double _clientDiscountPercent = 5.0;
  int _commissionMonths = 3;
  bool _settingsLoaded = false;

  bool get _isPendingNotApproved {
    return widget.selectedProduct.status == 'pending' &&
        !widget.selectedProduct.adminApproved;
  }

  bool get _showRentButton {
    final type = widget.selectedProduct.listingType;
    return type == 'rent' || type == 'rent_and_sale';
  }

  bool get _showSaleButton {
    final type = widget.selectedProduct.listingType;
    return type == 'sale' || type == 'rent_and_sale';
  }

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
    if (mounted) setState(() => _settingsLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final hasShownDialog = ref.watch(discountDialogShownProvider);
    final width = MediaQuery.of(context).size.width;
    final isFavorite = ref.watch(
      favoriteItemListProvider.select(
        (favorites) => favorites.contains(widget.selectedProduct),
      ),
    );
    final favoriteHouseListNotifier = ref.read(
      favoriteItemListProvider.notifier,
    );

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
                  widget.selectedProduct.thumbnailUrl ??
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
                if (widget.selectedProduct.units > 0)
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.house,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.selectedProduct.units} Units',
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
                if (widget.selectedProduct.status == 'pending')
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

            // ─── Action Buttons ────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Pending reason banner
                  if (widget.selectedProduct.status == 'pending' &&
                      widget.selectedProduct.pendingReason != null &&
                      widget.selectedProduct.pendingReason!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.selectedProduct.pendingReason!,
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Booking / Buy buttons
                  if (widget.selectedProduct.isActive &&
                      (_showRentButton || _showSaleButton))
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isWide = constraints.maxWidth > 400;
                        final bool hasBoth = _showRentButton && _showSaleButton;

                        if (_isPendingNotApproved) {
                          return _buildBookingButton('rent');
                        }

                        if (isWide && hasBoth) {
                          return Row(
                            children: [
                              if (_showRentButton)
                                Expanded(child: _buildBookingButton('rent')),
                              const SizedBox(width: 10),
                              if (_showSaleButton)
                                Expanded(child: _buildBookingButton('sale')),
                            ],
                          );
                        } else if (isWide && _showRentButton) {
                          return _buildBookingButton('rent');
                        } else if (isWide && _showSaleButton) {
                          return _buildBookingButton('sale');
                        } else {
                          return Column(
                            children: [
                              if (_showRentButton)
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: _showSaleButton ? 10 : 0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: _buildBookingButton('rent'),
                                  ),
                                ),
                              if (_showSaleButton)
                                SizedBox(
                                  width: double.infinity,
                                  child: _buildBookingButton('sale'),
                                ),
                            ],
                          );
                        }
                      },
                    ),
                ],
              ),
            ),

            // ─── Title + Price with View Count ────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.selectedProduct.propertyType,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.selectedProduct.viewCount != null &&
                          widget.selectedProduct.viewCount! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.selectedProduct.viewCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ─── Venue Packages ──────────────────────
                  if (widget.selectedProduct.venuePricing != null &&
                      widget.selectedProduct.venuePricing!.isNotEmpty) ...[
                    const Text(
                      'Venue Packages',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    ...widget.selectedProduct.venuePricing!.entries.map((entry) {
                      final icons = {
                        'daily': Icons.today,
                        'weekly': Icons.view_week,
                        'monthly': Icons.calendar_month,
                        'yearly': Icons.calendar_today,
                      };
                      final labels = {
                        'daily': 'Per Day',
                        'weekly': 'Per Week',
                        'monthly': 'Per Month',
                        'yearly': 'Per Year',
                      };
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(children: [
                          Icon(icons[entry.key] ?? Icons.attach_money,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            '${entry.key[0].toUpperCase()}${entry.key.substring(1)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const Spacer(),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'UGX ${NumberFormat('#,###').format(double.tryParse(entry.value.toString()) ?? 0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                      fontSize: 15),
                                ),
                                Text(
                                  labels[entry.key] ?? '',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[600]),
                                ),
                              ]),
                        ]),
                      );
                    }).toList(),
                  ]
                  // ─── Regular Rent Price ──────────────────
                  else if (widget.selectedProduct.rentPrice != null &&
                      widget.selectedProduct.rentPrice! > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.selectedProduct.numberOfMonths.isNotEmpty &&
                            widget.selectedProduct.numberOfMonths != '0' &&
                            widget.selectedProduct.numberOfMonths != 'null')
                          Text(
                            'Min. ${widget.selectedProduct.numberOfMonths} month${int.tryParse(widget.selectedProduct.numberOfMonths) != null && int.parse(widget.selectedProduct.numberOfMonths) > 1 ? "s" : ""}',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                        Text(
                          'UGX ${NumberFormat('#,###').format(widget.selectedProduct.rentPrice)}/mo',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ],

                  // ─── Sale Price ──────────────────────────
                  if (widget.selectedProduct.salePrice != null &&
                      widget.selectedProduct.salePrice! > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sale Price:',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700])),
                        Text(
                          'UGX ${NumberFormat('#,###').format(widget.selectedProduct.salePrice)}',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ─── Sale Conditions Box ───────────────────────
            if (widget.selectedProduct.isSale &&
                widget.selectedProduct.enteredSalePrice > 0 &&
                !(widget.selectedProduct.salePrice != null &&
                    widget.selectedProduct.salePrice! > 0))
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
                        style:
                            TextStyle(color: Colors.grey[700], fontSize: 13),
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
                      widget.selectedProduct.location,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 2),
                  Text('${widget.selectedProduct.starRating}'),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '(${widget.selectedProduct.reviews.toInt()} reviews)',
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Amenities ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildAmenitiesFromList(widget.selectedProduct),
            ),

            // ─── Featured Media ────────────────────────────
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

            if (widget.selectedProduct.insideViews.isNotEmpty ||
                widget.selectedProduct.videoPath != null)
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _getMediaCount(widget.selectedProduct),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    if (widget.selectedProduct.videoPath != null && i == 0) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenGallery(
                              mediaUrls: _getAllMedia(widget.selectedProduct),
                              initialIndex: i,
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
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
                          widget.selectedProduct.videoPath != null ? i - 1 : i;
                      final imgPath =
                          widget.selectedProduct.insideViews[imgIndex];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenGallery(
                              mediaUrls: _getAllMedia(widget.selectedProduct),
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
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No featured media available',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            if (widget.selectedProduct.insideViews.isNotEmpty ||
                widget.selectedProduct.videoPath != null)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GalleryView(
                      mediaUrls: _getAllMedia(widget.selectedProduct),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_library_outlined),
                    const SizedBox(width: 4),
                    Text(
                      'View All Media (${_getMediaCount(widget.selectedProduct)})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

            // ─── Description ───────────────────────────────
            if (!_isPendingNotApproved) ...[
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
                  widget.selectedProduct.description,
                  style: const TextStyle(height: 1.5),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.lock_outline,
                          color: Colors.orange[700], size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Property Details Not Available',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Full property details will be displayed here. You can save it to your favourites and check back later.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.orange[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── Booking / Buy Button Builder ──────────────────────
  Widget _buildBookingButton(String type) {
    if (_isPendingNotApproved) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.orange[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_actions, color: Colors.orange[700], size: 18),
            const SizedBox(width: 8),
            Text(
              'Not yet Available For Booking',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (type == 'rent') {
      return ElevatedButton.icon(
        onPressed: () => MainNavigation.navigateToRoute(
          MainNavigation.paymentMethodRoute,
          data: widget.selectedProduct,
        ),
        icon: const Icon(Icons.calendar_month, color: Colors.white, size: 18),
        label: const Text(
          'Book Now',
          style: TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: ()=> BrickContactDialog.show(
          context,
          property: widget.selectedProduct,
        ),
        icon: const Icon(Icons.handshake, color: Colors.white, size: 18),
        label: const Text(
          'Buy',
          style: TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
    }
  }

  // ─── Discount Dialog ──────────────────────────────────────
  void _showDiscountDialog(BuildContext context) {
    final isVenue = widget.selectedProduct.propertyType == 'Venue' ||
        widget.selectedProduct.propertyType == 'Ceremony Ground';
    final isLand = widget.selectedProduct.propertyType == 'Land';
    final isRent = widget.selectedProduct.listingType == 'rent' ||
        widget.selectedProduct.listingType == 'rent_and_sale';

    double price = 0;
    String priceLabel = '';
    String discountLabel = '';
    String firstPaymentLabel = '';
    double discountedPrice = 0;
    String savingsLabel = '';

    if (isVenue) {
      price = widget.selectedProduct.dailyPrice ??
          widget.selectedProduct.rentPrice ??
          widget.selectedProduct.price;
      priceLabel = 'UGX ${_fmt(price)}/day';

      final discountAmount = price * (_clientDiscountPercent / 100);
      discountedPrice = price - discountAmount;

      discountLabel =
          'Get ${_clientDiscountPercent.toStringAsFixed(0)}% off on your booking';
      firstPaymentLabel = 'First day you pay:';
      savingsLabel = 'You can save up to: UGX ${_fmt(discountAmount)} per day';
    } else if (isLand) {
      return;
    } else if (isRent) {
      price =
          widget.selectedProduct.rentPrice ?? widget.selectedProduct.price;
      priceLabel = 'UGX ${_fmt(price)}/month';

      final minimumMonths = int.tryParse(
              widget.selectedProduct.numberOfMonths.isEmpty ||
                      widget.selectedProduct.numberOfMonths == 'null'
                  ? '1'
                  : widget.selectedProduct.numberOfMonths) ??
          1;

      final commMonths = minimumMonths < _commissionMonths
          ? minimumMonths
          : _commissionMonths;
      final discountAmount =
          price * commMonths * (_clientDiscountPercent / 100);
      discountedPrice = price * (1 - _clientDiscountPercent / 100);

      discountLabel =
          'Get ${_clientDiscountPercent.toStringAsFixed(0)}% off on first $commMonths month${commMonths > 1 ? "s" : ""}';
      firstPaymentLabel = 'First month you pay:';
      savingsLabel = 'You can save up to: UGX ${_fmt(discountAmount)}';
    } else {
      final salePrice = widget.selectedProduct.salePrice ??
          widget.selectedProduct.enteredSalePrice;
      if (salePrice <= 0) return;

      price = salePrice;
      priceLabel = 'UGX ${_fmt(price)}';

      final discountAmount = price * (_clientDiscountPercent / 100);
      discountedPrice = price - discountAmount;

      discountLabel =
          'Get ${_clientDiscountPercent.toStringAsFixed(0)}% off on the sale price';
      firstPaymentLabel = 'You pay:';
      savingsLabel = 'You can save up to: UGX ${_fmt(discountAmount)}';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Brick Exclusive Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (price > 0) ...[
              Text(
                priceLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (isRent && !isVenue) ...[
              Builder(
                builder: (context) {
                  final minimumMonths = int.tryParse(
                          widget.selectedProduct.numberOfMonths.isEmpty ||
                                  widget.selectedProduct.numberOfMonths ==
                                      'null'
                              ? '1'
                              : widget.selectedProduct.numberOfMonths) ??
                      1;
                  if (minimumMonths > 0) {
                    return Text(
                      'Minimum: $minimumMonths month${minimumMonths > 1 ? "s" : ""}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
            const SizedBox(height: 12),
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
                          text: discountLabel,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    savingsLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (price > 0)
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
                    Text(
                      firstPaymentLabel,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'UGX ${_fmt(discountedPrice)}',
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
              '💡 Refund available within 24 hours of booking.',
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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

      return Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.start,
          children: amenityWidgets,
        ),
      );
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

    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.start,
        children: amenities,
      ),
    );
  }

  String _fmt(double value) {
    final formatted = value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return formatted;
  }
}