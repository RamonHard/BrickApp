import 'dart:io';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/pManagerPages/map_location_picker_page.dart';
import 'package:brickapp/pages/pManagerPages/pdf_pre_view.dart';
import 'package:brickapp/providers/product_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:brickapp/utils/urls.dart';
import 'package:brickapp/providers/user_provider.dart';

class AddPost extends ConsumerStatefulWidget {
  final PropertyModel? editPostModel; // Add this for editing existing post

  const AddPost({super.key, this.editPostModel});

  @override
  ConsumerState<AddPost> createState() => _AddPostState();
}

class _AddPostState extends ConsumerState<AddPost> {
  final style = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextColor,
  );

  String _location = "Kampala, Uganda"; // Default text
  String salesCondition = '';
  bool _isLoadingLocation = false;
  List<XFile> _selectedVideos = [];
  XFile? _selectedVideo;
  bool _isVideo = false;

  // Updated packages with custom option
  final List<String> packages = [
    '1 Month',
    '2 Months',
    '3 Months',
    '6 Months',
    '1 Year',
    '2 Years',
    'Custom Months',
  ];

  String? selectedPackage;
  int? customMonths; // For custom months input
  int? price;
  int? salePrice;
  double? landPercentage; // For land percentage
  int? discount;
  int? commission;
  XFile? _thumbnailPhoto;

  // Add this for rules and regulations document
  XFile? _rulesDocument;

  final currencyFormatter = NumberFormat("#,##0", "en_US");

  // Helper method to get month count from package string
  int _getMonthCount(String pkg) {
    switch (pkg) {
      case '1 Month':
        return 1;
      case '2 Months':
        return 2;
      case '3 Months':
        return 3;
      case '6 Months':
        return 6;
      case '1 Year':
        return 12;
      case '2 Years':
        return 24;
      default:
        return 1;
    }
  }

  // Calculate total price
  double _calculateTotalPrice() {
    if (_propertyType == 'Land') {
      return (landPercentage ?? 0).toDouble();
    }

    if (!_isRentSelected || price == null) {
      return 0.0;
    }

    int numberOfMonths = 0;

    if (selectedPackage == 'Custom Months') {
      numberOfMonths = customMonths ?? 0;
    } else {
      numberOfMonths = _getMonthCount(selectedPackage ?? '');
    }

    // Calculate total price: monthly price × number of months
    int total = (price ?? 0) * numberOfMonths;

    // Subtract discount if applicable
    if (discount != null && discount! > 0) {
      total -= (discount ?? 0);
    }

    return total.toDouble();
  }

  // Initialize data when editing an existing post
  @override
  void initState() {
    super.initState();
    if (widget.editPostModel != null) {
      _initializeEditData();
    }
  }

  void _initializeEditData() {
    final post = widget.editPostModel!;
    setState(() {
      // Basic info
      _propertyType = post.propertyType ?? 'House';
      _houseType = post.propertyType ?? 'Residential';
      _location = post.location ?? 'Kampala, Uganda';
      _descriptionController.text = post.description ?? '';

      // Pricing
      price = post.rentPrice?.toInt() ?? 0;
      salePrice = post.salePrice?.toInt();
      discount = post.discount?.toInt();
      commission = post.commission?.toInt();
      landPercentage = post.landPercentage;
      _currency = post.currency ?? 'USD';

      // Package info
      selectedPackage = post.package;
      if (post.package?.contains('Custom') ?? false) {
        final match = RegExp(r'(\d+)').firstMatch(post.package ?? '');
        customMonths = match != null ? int.parse(match.group(1)!) : 0;
      }

      // Boolean flags
      _isRentSelected = post.isRent ?? false;
      _isSaleSelected = post.isSale ?? false;
      _isActive = post.isActive ?? true;
      salesCondition = post.saleConditions ?? '';
      _pendingReasonController.text = post.pendingReason ?? '';

      // Property details
      _bedroomsController.text = post.bedrooms?.toString() ?? '';
      _bathsController.text = post.baths?.toString() ?? '';
      _sqftController.text = post.sqft?.toString() ?? '';
      _unitsController.text = post.units?.toString() ?? '';

      // Amenities
      _hasParking = post.hasParking ?? false;
      _isFurnished = post.isFurnished ?? false;
      _hasAC = post.hasAC ?? false;
      _hasInternet = post.hasInternet ?? false;
      _hasSecurity = post.hasSecurity ?? false;
      _hasCompound = post.hasCompound ?? false;
      _isPetFriendly = post.isPetFriendly ?? false;

      // Photos (can't pre-load XFile from paths)
      if (post.thumbnail != null && post.thumbnail!.isNotEmpty) {
        _thumbnailPhoto = XFile(post.thumbnail!);
      }
    });
  }

  void showPriceDialog(String pkg) {
    final priceController = TextEditingController(
      text: price?.toString() ?? '600000',
    );

    final customMonthsController = TextEditingController(
      text: customMonths?.toString() ?? '',
    );

    int dialogDiscount = discount ?? 30000;
    int dialogCommission = commission ?? 18000;

    bool isLandProperty = _propertyType == 'Land';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Row(
                    children: [
                      Text(
                        pkg == 'Custom Months'
                            ? 'Set Custom Package'
                            : 'Set Price for $pkg',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                      Expanded(child: Container()),
                      IconButton(
                        tooltip: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Color.fromARGB(255, 197, 13, 0),
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Custom months input if Custom is selected
                        if (pkg == 'Custom Months') ...[
                          TextField(
                            controller: customMonthsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Enter Number of Months',
                              hintText: 'e.g., 9, 15, 24',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // For land, show percentage input instead of price
                        if (isLandProperty) ...[
                          TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price per Square Meter (%)',
                              hintText: 'Enter percentage',
                              suffixText: '%',
                            ),
                            onChanged: (value) {
                              final enteredPercentage =
                                  int.tryParse(value) ?? 0;
                              setStateDialog(() {
                                dialogCommission =
                                    (enteredPercentage * 0.1)
                                        .toInt(); // 10% commission of percentage
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Note: For land, this is the percentage of total value',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ] else ...[
                          TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  pkg == 'Custom Months'
                                      ? 'Enter Monthly Price'
                                      : 'Enter Price',
                            ),
                            onChanged: (value) {
                              final enteredPrice = int.tryParse(value) ?? 0;
                              setStateDialog(() {
                                dialogDiscount = (enteredPrice * 0.05).toInt();
                                dialogCommission =
                                    (enteredPrice * 0.03).toInt();
                              });
                            },
                          ),
                        ],

                        const SizedBox(height: 16),
                        Text(
                          'Selected Package: ${pkg == 'Custom Months' ? 'Custom' : pkg}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (isLandProperty) ...[
                          Text(
                            'Percentage: ${int.tryParse(priceController.text) ?? 0}%',
                            style: style,
                          ),
                        ] else ...[
                          Text(
                            '${pkg == 'Custom Months' ? 'Monthly' : ''} Price: UGX${currencyFormatter.format(int.tryParse(priceController.text) ?? 0)}',
                            style: style,
                          ),
                        ],

                        if (!isLandProperty) ...[
                          Text(
                            'Discount: UGX${currencyFormatter.format(dialogDiscount)}',
                            style: style,
                          ),
                          Text(
                            'Commission: UGX${currencyFormatter.format(dialogCommission)}',
                            style: style,
                          ),
                        ],

                        if (pkg != 'Custom Months' &&
                            pkg.contains('Month') &&
                            !isLandProperty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Total for $pkg: UGX${currencyFormatter.format((int.tryParse(priceController.text) ?? 0) * _getMonthCount(pkg))}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),

                        if (pkg == 'Custom Months' &&
                            customMonthsController.text.isNotEmpty &&
                            !isLandProperty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Price Breakdown:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Monthly: UGX${currencyFormatter.format(int.tryParse(priceController.text) ?? 0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  Text(
                                    'Duration: ${customMonthsController.text} months',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  const Divider(color: Colors.green),
                                  Text(
                                    'Total: UGX${currencyFormatter.format((int.tryParse(priceController.text) ?? 0) * (int.tryParse(customMonthsController.text) ?? 1))}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[900],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final enteredPrice =
                            int.tryParse(priceController.text) ?? 0;
                        final enteredCustomMonths =
                            int.tryParse(customMonthsController.text) ?? 0;

                        setState(() {
                          selectedPackage = pkg;

                          if (isLandProperty) {
                            // For land, store percentage
                            landPercentage = enteredPrice.toDouble();
                            price =
                                enteredPrice; // Still use price for backward compatibility
                          } else {
                            price = enteredPrice;
                          }

                          if (pkg == 'Custom Months') {
                            customMonths = enteredCustomMonths;
                          }

                          if (!isLandProperty) {
                            discount = (enteredPrice * 0.05).toInt();
                            commission = (enteredPrice * 0.03).toInt();
                          } else {
                            // For land, commission might be percentage of sale price
                            commission =
                                (enteredPrice * 0.1)
                                    .toInt(); // 10% of the percentage
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget buildPackageCard(String pkg) {
    bool isLandProperty = _propertyType == 'Land';

    return GestureDetector(
      onTap: () => showPriceDialog(pkg),
      child: Card(
        elevation: 8,
        color:
            selectedPackage == pkg
                ? AppColors.iconColor.withOpacity(0.6)
                : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                pkg,
                style: TextStyle(
                  color: selectedPackage == pkg ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.key_sharp,
                color: isLandProperty ? Colors.orange : AppColors.darkBg,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated buildSelectedInfo to show custom months and total price
  Widget buildSelectedInfo() {
    if (selectedPackage == null && salePrice == null) return const SizedBox();

    bool isLandProperty = _propertyType == 'Land';
    double totalPrice = _calculateTotalPrice();

    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 20,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show rental package info if selected
            if (selectedPackage != null) ...[
              Row(
                children: [
                  Text(
                    selectedPackage == 'Custom Months'
                        ? 'Custom Package: ${customMonths ?? 0} Months'
                        : 'Package: $selectedPackage',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isLandProperty ? Colors.orange[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isLandProperty ? 'Land' : 'Rental',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            isLandProperty
                                ? Colors.orange[700]
                                : Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (isLandProperty) ...[
                Text(
                  'Land Percentage: ${landPercentage ?? 0}%',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Commission: $commission% of total value',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ] else ...[
                Text(
                  'Monthly Price: UGX${currencyFormatter.format(price ?? 0)}',
                ),
                if (customMonths != null && customMonths! > 0)
                  Text('Duration: $customMonths months'),
                if (discount != null && discount! > 0)
                  //   Text(
                  //     'Discount: UGX${currencyFormatter.format(discount ?? 0)}',
                  //   ),
                  // Text(
                  //   'Commission: UGX${currencyFormatter.format(commission ?? 0)}',
                  // ),
                  // Show total price
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calculate,
                          color: Colors.green[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Total Price: UGX${currencyFormatter.format(totalPrice.toInt())}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],

            // Add divider if both rental and sale are selected
            if (selectedPackage != null && salePrice != null) ...[
              const SizedBox(height: 12),
              const Divider(thickness: 1),
              const SizedBox(height: 8),
            ],

            // Show sale info if selected
            if (salePrice != null) ...[
              Row(
                children: [
                  Text(
                    'Sale Information',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: const Text(
                      'For Sale',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sale Price: UGX${currencyFormatter.format(salePrice ?? 0)}',
              ),
              if (salesCondition.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Conditions: $salesCondition',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // Controllers
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _dailyPriceController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathsController = TextEditingController();
  final TextEditingController _sqftController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _saleConditionsController =
      TextEditingController();
  final TextEditingController _pendingReasonController =
      TextEditingController();

  // Form fields
  String _currency = 'USD';
  String _propertyType = 'House';
  String _houseType = 'Residential'; // Added house type field

  bool _hasParking = false;
  bool _isFurnished = false;
  bool _hasAC = false;
  bool _hasInternet = false;
  bool _hasSecurity = false;
  bool _isPetFriendly = false;
  bool _isActive = true;
  bool _isRentSelected = false;
  bool _isSaleSelected = false;
  bool _hasCompound = false; // Added hasCompound field
  int _photosCount = 0;
  List<XFile> _selectedPhotos = [];

  // Add amenities list
  List<String> get _amenities {
    List<String> amenities = [];
    if (_hasParking) amenities.add('Parking');
    if (_isFurnished) amenities.add('Furnished');
    if (_hasAC) amenities.add('Air Conditioning');
    if (_hasInternet) amenities.add('Internet');
    if (_hasSecurity) amenities.add('Security');
    if (_isPetFriendly) amenities.add('Pet Friendly');
    if (_hasCompound) amenities.add('Compound');
    return amenities;
  }

  bool _isSubmitting = false;
  @override
  Widget build(BuildContext context) {
    bool showHouseSections =
        _propertyType == 'House' ||
        _propertyType == 'Apartments' ||
        _propertyType == 'Business Shop' ||
        _propertyType == 'Warehouse' ||
        _propertyType == 'Storage Facility' ||
        _propertyType == 'Industrial Building' ||
        _propertyType == 'Office Space';

    bool isLandProperty = _propertyType == 'Land';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          widget.editPostModel != null ? 'Edit Property' : 'Post Your Property',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Property Type'),
              _buildPropertyTypeDropdown(),
              const SizedBox(height: 20),

              if (!isLandProperty) ...[
                _buildSectionTitle('Select Property Type'),
                _buildHouseTypeDropdown(),
                const SizedBox(height: 20),
              ],

              _buildSectionTitle('Location'),
              _buildLocationPicker(),
              const SizedBox(height: 20),

              if (_propertyType != 'Venue') ...[
                _buildSectionTitle("Listing Type"),
                _buildListingTypeButtons(),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 20),
              // After _buildListingTypeButtons()
              if (_propertyType == 'Venue' ||
                  _propertyType == 'Ceremony Ground') ...[
                const SizedBox(height: 20),
                _buildSectionTitle('Daily Price (UGX)'),
                Container(
                  height: 50,
                  child: TextField(
                    controller: _dailyPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter daily price e.g. 500000',
                      prefixText: 'UGX ',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],

              _buildSectionTitle(
                isLandProperty
                    ? 'Set Land Percentage'
                    : 'Set Rental Price Package',
              ),
              showHouseSections || isLandProperty
                  ? (_propertyType == 'Farm House'
                      ? const SizedBox() // ✅ no packages for venue
                      : SizedBox(
                        height: 100,
                        child:
                            _isRentSelected || isLandProperty
                                ? ListView(
                                  scrollDirection: Axis.horizontal,
                                  children:
                                      packages.map(buildPackageCard).toList(),
                                )
                                : Center(
                                  child: Text(
                                    isLandProperty
                                        ? "Select a package for land"
                                        : "Select 'Rent' to choose a package",
                                    style: style,
                                  ),
                                ),
                      ))
                  : _buildPriceField(),
              const SizedBox(height: 10),

              buildSelectedInfo(),
              const SizedBox(height: 20),

              if (showHouseSections) ...[
                _buildSectionTitle('Basic Information'),
                _buildBasicInfoFields(),
                const SizedBox(height: 20),

                _buildUnitsField(),
                const SizedBox(height: 20),

                _buildSectionTitle('Amenities'),
                _buildAmenitiesGrid(),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 20),

              _buildSectionTitle('Description'),
              _buildDescriptionField(),
              const SizedBox(height: 20),

              // Add Rules & Regulations Document Section
              _buildSectionTitle('Rules & Regulations (Optional)'),
              _buildRulesDocumentSection(),
              const SizedBox(height: 20),

              _buildSectionTitle('Add Photos'),
              _buildPhotosSection(),
              const SizedBox(height: 20),
              _buildThumbnailSection(),
              const SizedBox(height: 20),

              _buildPostButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Add this new method for rules document upload
  Widget _buildRulesDocumentSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _rulesDocument != null
                    ? Icons.picture_as_pdf
                    : Icons.upload_file,
              ),
            ),
            title: Text(
              _rulesDocument != null
                  ? _rulesDocument!.name
                  : 'Upload Rules & Regulations',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              _rulesDocument != null
                  ? 'Tap to replace'
                  : 'PDF, DOC, or TXT (Max 10MB)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_rulesDocument != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _rulesDocument = null;
                      });
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.cloud_upload, color: Colors.blue),
                  onPressed: _pickRulesDocument,
                ),
              ],
            ),
          ),
          if (_rulesDocument != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: LinearProgressIndicator(
                value: 1.0, // Show 100% when uploaded
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          if (_rulesDocument != null)
            TextButton.icon(
              icon: const Icon(Icons.visibility),
              label: const Text("Preview Document"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => DocumentPreviewScreen(
                          filePath: _rulesDocument!.path,
                          title: "Preview Document",
                        ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Add method to pick document
  Future<void> _pickRulesDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // File size check (10MB)
        final size = await file.length();
        if (size > 10 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File must be less than 10MB')),
          );
          return;
        }

        setState(() {
          _rulesDocument = XFile(file.path); // keep your existing model
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.single.name} uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  // Add house type dropdown
  Widget _buildHouseTypeDropdown() {
    List<String> houseTypes = [
      'Residential',
      'Commercial',
      'Industrial',
      'Agricultural',
    ];

    return DropdownButtonFormField<String>(
      value: _houseType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items:
          houseTypes.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: (newValue) {
        setState(() {
          _houseType = newValue!;
        });
      },
    );
  }

  Widget _buildListingTypeButtons() {
    return Row(
      children: [
        MaterialButton(
          height: 40,
          onPressed: () => setState(() => _isRentSelected = !_isRentSelected),
          color:
              _isRentSelected
                  ? Colors.green
                  : const Color.fromARGB(117, 43, 43, 43),
          padding: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            "Rent",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 5.0),
        MaterialButton(
          height: 40,
          onPressed: () {
            // Show dialog when Sale button is clicked
            showSalePriceDialog();
          },
          color:
              _isSaleSelected
                  ? Colors.green
                  : const Color.fromARGB(117, 43, 43, 43),
          padding: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            "Sale",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void showSalePriceDialog() {
    final salePriceController = TextEditingController(
      text: salePrice?.toString() ?? '',
    );

    final saleConditionsController = TextEditingController(
      text: salesCondition,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Text(
                  'Set Sale Price',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextColor,
                  ),
                ),
                Expanded(child: Container()),
                IconButton(
                  tooltip: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Color.fromARGB(255, 197, 13, 0),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: salePriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Sale Price',
                      prefixText: 'UGX ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: saleConditionsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Sale Conditions (Optional)',
                      hintText: 'e.g., Negotiable, Cash only, etc.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (salePriceController.text.isNotEmpty)
                    Text(
                      'Sale Price: UGX${currencyFormatter.format(int.tryParse(salePriceController.text) ?? 0)}',
                      style: style,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final enteredSalePrice =
                      int.tryParse(salePriceController.text) ?? 0;
                  setState(() {
                    salePrice = enteredSalePrice;
                    salesCondition = saleConditionsController.text;
                    if (enteredSalePrice > 0) {
                      _isSaleSelected = true;
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  // Updated _updatePostData method with rules document and total price
  Future<void> _updatePostData() async {
    bool isLandProperty = _propertyType == 'Land';

    // Basic validation
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please add a description')));
      return;
    }

    if (_selectedPhotos.isEmpty && _thumbnailPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo')),
      );
      return;
    }

    final isVenue =
        _propertyType == 'Venue' || _propertyType == 'Ceremony Ground';
    if (!_isRentSelected && !_isSaleSelected && !isLandProperty && !isVenue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Rent or Sale listing type'),
        ),
      );
      return;
    }

    // Show loading
    setState(() => _isSubmitting = true);

    try {
      final token = ref.read(userProvider).token;

      if (token == null) {
        setState(() => _isSubmitting = false); // close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('You must be logged in')));
        return;
      }

      // Build multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppUrls.properties + '/create'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Text fields
      request.fields['property_type'] = _propertyType;
      request.fields['description'] = _descriptionController.text.trim();
      request.fields['address'] = _location;
      request.fields['status'] = _isActive ? 'active' : 'pending';
      request.fields['currency'] = _currency;

      // Listing type
      if (_isRentSelected && _isSaleSelected) {
        request.fields['listing_type'] = 'rent_and_sale';
      } else if (_isRentSelected) {
        request.fields['listing_type'] = 'rent';
      } else if (_isSaleSelected) {
        request.fields['listing_type'] = 'sale';
      }

      // Pricing
      if (price != null && price! > 0) {
        request.fields['rent_price'] = price.toString();
      }
      if (salePrice != null && salePrice! > 0) {
        request.fields['sale_price'] = salePrice.toString();
        request.fields['sale_condition'] = salesCondition;
      }
      // After the rent_price/sale_price fields
      if (_propertyType == 'Venue' || _propertyType == 'Ceremony Ground') {
        if (_dailyPriceController.text.isNotEmpty) {
          request.fields['daily_price'] = _dailyPriceController.text;
          request.fields['listing_type'] = 'rent'; // venues are always rent
        }
      }
      // Duration
      if (selectedPackage != null) {
        final months =
            selectedPackage == 'Custom Months'
                ? (customMonths ?? 1)
                : _getMonthCount(selectedPackage!);
        request.fields['rent_duration_months'] = months.toString();
      }

      // Property details
      if (_bedroomsController.text.isNotEmpty) {
        request.fields['bedrooms'] = _bedroomsController.text;
      }
      if (_bathsController.text.isNotEmpty) {
        request.fields['bathrooms'] = _bathsController.text;
      }
      if (_sqftController.text.isNotEmpty) {
        request.fields['square_feet'] = _sqftController.text;
      }
      if (_unitsController.text.isNotEmpty) {
        request.fields['units'] = _unitsController.text;
      }
      if (!_isActive && _pendingReasonController.text.isNotEmpty) {
        request.fields['pending_reason'] = _pendingReasonController.text;
      }

      // Amenities as comma separated string
      request.fields['amenities'] = _amenities.join(',');

      // Land specific
      if (isLandProperty && landPercentage != null) {
        request.fields['land_percentage'] = landPercentage.toString();
      }

      // Images
      for (final photo in _selectedPhotos) {
        request.files.add(
          await http.MultipartFile.fromPath('images', photo.path),
        );
      }

      // Thumbnail (add as first image if no other photos)
      if (_thumbnailPhoto != null) {
        request.files.add(
          await http.MultipartFile.fromPath('images', _thumbnailPhoto!.path),
        );
      }

      // Video
      if (_selectedVideo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('video', _selectedVideo!.path),
        );
      }

      // Rules document
      if (_rulesDocument != null) {
        request.files.add(
          await http.MultipartFile.fromPath('document', _rulesDocument!.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      print('ADD PROPERTY RESPONSE: $data');

      setState(() => _isSubmitting = false); // ✅ stop loading

      if (response.statusCode == 200 && data['status'] == true) {
        final newProperty = PropertyModel.fromJson(data['property']);
        ref.read(productProvider.notifier).addProduct(newProperty);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to post property'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false); // ✅ stop loading on error
      print('Error posting property: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickPhotos() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        // Only keep up to 10 photos
        if (_selectedPhotos.length + pickedFiles.length <= 10) {
          _selectedPhotos.addAll(pickedFiles);
        } else {
          final remainingSlots = 10 - _selectedPhotos.length;
          _selectedPhotos.addAll(pickedFiles.take(remainingSlots));
        }
      });
    }
  }

  // Update the post button to call the correct method
  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _updatePostData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            _isSubmitting
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  widget.editPostModel != null
                      ? 'Update Property'
                      : 'Post Property',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.lightGrey,
        ),
      ),
    );
  }

  Widget _buildPropertyTypeDropdown() {
    List<String> propertyTypes = [
      'House',
      'Land',
      'Venue',
      'Apartments',
      'Office Space',
      'Warehouse',
      'Farm House',
      'Industrial Building',
      'Storage Facility',
      'Business Shop',
    ];

    return DropdownButtonFormField<String>(
      value: _propertyType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items:
          propertyTypes.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: (newValue) {
        setState(() {
          _propertyType = newValue!;
        });
      },
    );
  }

  Widget _buildPriceField() {
    return Row(
      children: [
        Container(
          height: 35,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: _currency,
                icon: const Icon(Icons.keyboard_arrow_down),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _currency = newValue;
                    });
                  }
                },
                items:
                    <String>[
                      'USD',
                      'EUR',
                      'GBP',
                      'UGX',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 35,
            child: TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Price',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoFields() {
    final style = GoogleFonts.poppins(
      fontSize: 14,
      color: Colors.black54,
      fontWeight: FontWeight.w600,
    );
    final inputStyle = GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextColor,
    );
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('~Bedrooms', style: style),
              ),
              SizedBox(
                height: 35,
                child: TextField(
                  controller: _bedroomsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: inputStyle,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.grid_view, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text('Baths', style: style),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: TextField(
                  controller: _bathsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: inputStyle,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.square_foot, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text('Sq ft', style: style),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: TextField(
                  controller: _sqftController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: inputStyle,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitsField() {
    final width = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0, top: 16.0),
              child: Text(
                'Number of Units',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightGrey,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  height: 35,
                  width: 65,
                  child: TextField(
                    controller: _unitsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Units',
                    ),
                  ),
                ),
                SizedBox(width: width / 10),
                // Active Button
                MaterialButton(
                  height: 40,
                  onPressed: () {
                    setState(() {
                      _isActive = true;
                    });
                  },
                  color:
                      _isActive
                          ? Colors.green
                          : const Color.fromARGB(117, 43, 43, 43),
                  padding: EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "Active",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 5.0),
                // Pending Button
                MaterialButton(
                  height: 40,
                  onPressed: () {
                    setState(() {
                      _isActive = false;
                    });
                  },
                  color:
                      !_isActive
                          ? Colors.orange
                          : const Color.fromARGB(117, 43, 43, 43),
                  padding: EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "Pending",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // ✅ Reveal this TextField only when status is "Pending"
            if (!_isActive) ...[
              SizedBox(height: 10),
              Text(
                'Reason for Pending',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightGrey,
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: width * 0.8,
                child: TextField(
                  controller:
                      _pendingReasonController, // Add this controller in your State
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Enter reason...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildAmenityItem(Icons.local_parking, 'Parking', _hasParking, (val) {
          setState(() => _hasParking = val);
        }),
        _buildAmenityItem(Icons.chair, 'Furnished', _isFurnished, (val) {
          setState(() => _isFurnished = val);
        }),
        _buildAmenityItem(Icons.ac_unit, 'AC', _hasAC, (val) {
          setState(() => _hasAC = val);
        }),
        _buildAmenityItem(Icons.wifi, 'Internet', _hasInternet, (val) {
          setState(() => _hasInternet = val);
        }),
        _buildAmenityItem(Icons.security, 'Security', _hasSecurity, (val) {
          setState(() => _hasSecurity = val);
        }),
        _buildAmenityItem(Icons.grass, 'Compound', _hasCompound, (val) {
          setState(() => _hasCompound = val);
        }),
        _buildAmenityItem(Icons.pets, 'Pet Friendly', _isPetFriendly, (val) {
          setState(() => _isPetFriendly = val);
        }),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildAmenityItem(
    IconData icon,
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                value
                    ? const Color.fromARGB(207, 255, 94, 0)
                    : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: value ? Colors.blue.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  value
                      ? const Color.fromARGB(207, 255, 94, 0)
                      : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      value
                          ? const Color.fromARGB(207, 255, 94, 0)
                          : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    return GestureDetector(
      onTap: _showLocationOptions,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child:
                    _isLoadingLocation
                        ? const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Getting location...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                        : Text(
                          _location,
                          style: TextStyle(
                            color:
                                _location == "Kampala, Uganda"
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.my_location, color: Colors.blue),
                  title: const Text('Use Current Location'),
                  onTap: () {
                    Navigator.pop(context);
                    _getCurrentLocation();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.map, color: Colors.green),
                  title: const Text('Choose from Map'),
                  onTap: () {
                    Navigator.pop(context);
                    _openMapPicker();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.search, color: Colors.orange),
                  title: const Text('Search Location'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSearchDialog();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError("Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError("Location permissions are permanently denied");
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "${place.locality}, ${place.administrativeArea}";

        setState(() {
          _location = address.isNotEmpty ? address : "Location selected";
        });

        // Store coordinates for later use if needed
        _saveLocationData(position.latitude, position.longitude, address);
      }
    } catch (e) {
      _showError("Error getting location: $e");
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _openMapPicker() {
    // Navigate to a map screen where user can pick location
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MapLocationPicker(
              onLocationSelected: (lat, lng, address) {
                setState(() {
                  _location = address;
                });
                _saveLocationData(lat, lng, address);
              },
            ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Location'),
            content: TextField(
              decoration: const InputDecoration(
                hintText: 'Enter address, city, or landmark...',
              ),
              onSubmitted: (value) async {
                if (value.isNotEmpty) {
                  await _searchLocation(value);
                  Navigator.pop(context);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Get text from field and search
                  final textField =
                      context.findAncestorStateOfType<State<TextField>>();
                  // This is simplified - you might need a TextEditingController
                  Navigator.pop(context);
                },
                child: const Text('Search'),
              ),
            ],
          ),
    );
  }

  Future<void> _searchLocation(String query) async {
    setState(() => _isLoadingLocation = true);

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          String address = "${place.name}, ${place.locality}";

          setState(() {
            _location = address;
          });
          _saveLocationData(location.latitude, location.longitude, address);
        }
      } else {
        _showError("Location not found");
      }
    } catch (e) {
      _showError("Error searching location: $e");
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _saveLocationData(double lat, double lng, String address) {
    // Save the location data for your form submission
    // You can store these in your state variables
    print("Location selected: $address ($lat, $lng)");

    // Add these variables to your state if needed:
    // double _selectedLat = lat;
    // double _selectedLng = lng;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle between photos and video
        Row(
          children: [
            Expanded(
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    _isVideo = false;
                  });
                },
                color: !_isVideo ? Colors.blue : Colors.grey[300],
                child: Text(
                  'Photos',
                  style: TextStyle(
                    color: !_isVideo ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    _isVideo = true;
                  });
                },
                color: _isVideo ? Colors.blue : Colors.grey[300],
                child: Text(
                  'Video',
                  style: TextStyle(
                    color: _isVideo ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),

        // Content based on selection
        _isVideo ? _buildVideoSection() : _buildImageSection(),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GestureDetector(
            onTap: _pickPhotos,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add up to 10 photos',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_selectedPhotos.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_selectedPhotos[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPhotos.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GestureDetector(
            onTap: _pickVideo,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.videocam, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add a short video',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_selectedVideo != null)
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black12,
                ),
                child: Icon(Icons.videocam, size: 40, color: Colors.grey),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedVideo = null;
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Text(
                  'Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildThumbnailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Thumbnail Image",
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.lightGrey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickThumbnail,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child:
                _thumbnailPhoto == null &&
                        widget.editPostModel?.thumbnail == null
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.image, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "Tap to add thumbnail",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                    : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              _thumbnailPhoto != null
                                  ? Image.file(
                                    File(_thumbnailPhoto!.path),
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.network(
                                    widget.editPostModel!.thumbnail!,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.error),
                                            ),
                                  ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _thumbnailPhoto = null;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _thumbnailPhoto = pickedFile;
      });
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 30), // Limit to 30 seconds
    );

    if (pickedFile != null) {
      // Check file size (limit to 10MB)
      final file = File(pickedFile.path);
      final stat = await file.stat();
      if (stat.size > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Video must be less than 10MB')));
        return;
      }

      setState(() {
        _selectedVideo = pickedFile;
      });
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _salePriceController.dispose();
    _dailyPriceController.dispose(); // ✅ add this
    _bedroomsController.dispose();
    _bathsController.dispose();
    _sqftController.dispose();
    _unitsController.dispose();
    _descriptionController.dispose();
    _saleConditionsController.dispose();
    _pendingReasonController.dispose();
    super.dispose();
  }
}
