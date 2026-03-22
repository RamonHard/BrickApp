import 'dart:io';
import 'package:brickapp/models/add_post_model.dart';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/pManagerPages/map_location_picker_page.dart';
import 'package:brickapp/providers/post_data_notifier.dart';
import 'package:brickapp/providers/product_provider.dart';
import 'package:brickapp/providers/property_providers.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class EditPost extends ConsumerStatefulWidget {
  final PropertyModel property; // Pass existing property data

  const EditPost({super.key, required this.property});

  @override
  ConsumerState<EditPost> createState() => _EditPostState();
}

class _EditPostState extends ConsumerState<EditPost> {
  final style = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextColor,
  );

  String _location = "Kampala, Uganda"; // Initialize with default value
  String salesCondition = ""; // Initialize with empty string
  bool _isLoadingLocation = false;
  List<XFile> _selectedVideos = [];
  XFile? _selectedVideo;
  XFile? _rulesDocument;
  bool _isVideo = false;
  final List<String> packages = ['1 Month', '2 Months', '3 Months'];
  String? selectedPackage;
  int? price;
  int? salePrice;
  int? discount;
  int? commission;
  XFile? _thumbnailPhoto;
  List<String> _existingPhotos = [];
  List<String> _photosToDelete = [];

  final currencyFormatter = NumberFormat("#,##0", "en_US");

  // Define property types list as a constant
  static const List<String> propertyTypes = [
    'House',
    'Land',
    'Ceremony Ground',
    'Apartments',
    'Office Space',
    'Warehouse',
    'Hotel',
    'Hostel',
    'Farm House',
    'Industrial Building',
    'Storage Facility',
    'Business Shop',
  ];

  void showPriceDialog(String pkg) {
    final priceController = TextEditingController(
      text: price?.toString() ?? '600000',
    );

    int dialogDiscount = discount ?? 30000;
    int dialogCommission = commission ?? 18000;

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
                        'Edit Price',
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
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Enter Price',
                        ),
                        onChanged: (value) {
                          final enteredPrice = int.tryParse(value) ?? 0;
                          setStateDialog(() {
                            dialogDiscount = (enteredPrice * 0.05).toInt();
                            dialogCommission = (enteredPrice * 0.03).toInt();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selected Package: $pkg',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Price: UGX${currencyFormatter.format(int.tryParse(priceController.text) ?? 0)}',
                        style: style,
                      ),
                      Text(
                        'Discount: UGX${currencyFormatter.format(dialogDiscount)}',
                        style: style,
                      ),
                      Text(
                        'Commission: UGX${currencyFormatter.format(dialogCommission)}',
                        style: style,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final enteredPrice =
                            int.tryParse(priceController.text) ?? 0;
                        setState(() {
                          selectedPackage = pkg;
                          price = enteredPrice;
                          discount = (enteredPrice * 0.05).toInt();
                          commission = (enteredPrice * 0.03).toInt();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget buildPackageCard(String pkg) {
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
              Icon(Icons.key_sharp, color: AppColors.darkBg),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSelectedInfo() {
    if (selectedPackage == null && salePrice == null) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 20,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedPackage != null) ...[
              Text(
                'Selected Package: $selectedPackage',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Rental Price: UGX${currencyFormatter.format(price ?? 0)}'),
              Text('Commission: 10%'),
            ],

            if (selectedPackage != null && salePrice != null) ...[
              const SizedBox(height: 12),
              const Divider(thickness: 1),
              const SizedBox(height: 8),
            ],

            if (salePrice != null) ...[
              Text(
                'Sale Information',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
  String _propertyType = 'House'; // Initialize with default value
  String _houseType = 'Residential';

  bool _hasParking = false;
  bool _isFurnished = false;
  bool _hasAC = false;
  bool _hasInternet = false;
  bool _hasSecurity = false;
  bool _isPetFriendly = false;
  bool _isActive = true;
  bool _isRentSelected = false;
  bool _isSaleSelected = false;
  bool _hasCompound = false;
  List<XFile> _selectedPhotos = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final property = widget.property;

    // Set basic info - Ensure propertyType is in the list
    _propertyType = property.propertyType;

    // If propertyType is not in the list, default to first item
    if (!propertyTypes.contains(_propertyType)) {
      _propertyType = propertyTypes.first;
    }

    _location = property.location;
    _houseType = property.destinationTitle ?? 'Residential';
    _descriptionController.text = property.description;

    // Set numeric values
    price = property.price.toInt();
    _priceController.text = property.price.toString();

    if (property.isSale && property.enteredSalePrice > 0) {
      salePrice = property.enteredSalePrice.toInt();
      _salePriceController.text = property.enteredSalePrice.toString();
      salesCondition = property.saleConditions ?? '';
      _saleConditionsController.text = salesCondition;
      _isSaleSelected = true;
    }

    if (property.isRent) {
      _isRentSelected = true;
      selectedPackage = property.package;
      discount = property.discount.toInt();
      commission = property.commission!.toInt();
    }

    // Set basic information
    _bedroomsController.text = property.bedrooms.toString();
    _bathsController.text = property.baths.toString();
    _sqftController.text = property.sqft.toString();
    _unitsController.text = property.units.toString();

    // Set amenities
    _hasParking = property.hasParking;
    _isFurnished = property.isFurnished;
    _hasAC = property.hasAC;
    _hasInternet = property.hasInternet;
    _hasSecurity = property.hasSecurity;
    _isPetFriendly = property.isPetFriendly;
    _hasCompound = property.hasCompound;

    // Set status
    _isActive = property.isActive;
    if (!_isActive && property.pendingReason != null) {
      _pendingReasonController.text = property.pendingReason!;
    }

    // Set existing photos
    _existingPhotos = property.insideViews ?? [];

    // Set video if exists
    if (property.videoPath != null && property.videoPath!.isNotEmpty) {
      _isVideo = true;
    }

    // Set currency if available
    _currency = property.currency ?? 'USD';

    // Initialize salesCondition if not already set
    if (salesCondition.isEmpty && property.saleConditions != null) {
      salesCondition = property.saleConditions!;
    }
  }

  List<String> get _amenities {
    List<String> amenities = [];
    if (_hasParking) amenities.add('Parking');
    if (_isFurnished) amenities.add('Furnished');
    if (_hasAC) amenities.add('Air Conditioning');
    if (_hasInternet) amenities.add('Internet');
    if (_hasSecurity) amenities.add('Security');
    if (_isPetFriendly) amenities.add('Pet Friendly');
    return amenities;
  }

  @override
  Widget build(BuildContext context) {
    bool showHouseSections =
        _propertyType == 'House' ||
        _propertyType == 'Apartments' ||
        _propertyType == 'Business Shop';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          'Edit Property',
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

              _buildSectionTitle('Select Property Type'),
              _buildHouseTypeDropdown(),
              const SizedBox(height: 20),

              _buildSectionTitle('Location'),
              _buildLocationPicker(),
              const SizedBox(height: 20),

              _buildSectionTitle("Listing Type"),
              _buildListingTypeButtons(),
              const SizedBox(height: 20),

              _buildSectionTitle('Set Rental Price Package'),
              showHouseSections
                  ? SizedBox(
                    height: 100,
                    child:
                        _isRentSelected
                            ? ListView(
                              scrollDirection: Axis.horizontal,
                              children: packages.map(buildPackageCard).toList(),
                            )
                            : Text(
                              "Select 'Rent' to choose a package",
                              style: style,
                            ),
                  )
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

              _buildSectionTitle('Photos & Videos'),
              _buildPhotosSection(),
              const SizedBox(height: 20),

              _buildThumbnailSection(),
              const SizedBox(height: 20),

              if (_existingPhotos.isNotEmpty) _buildExistingPhotosSection(),
              const SizedBox(height: 20),

              _buildUpdateButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHouseTypeDropdown() {
    List<String> houseTypes = [
      'Residential',
      'Commercial',
      'Industrial',
      'Agricultural',
    ];

    // Ensure the current value is in the list
    String currentValue = _houseType;
    if (!houseTypes.contains(currentValue)) {
      currentValue = houseTypes.first;
      _houseType = currentValue;
    }

    return DropdownButtonFormField<String>(
      value: currentValue,
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
        if (newValue != null) {
          setState(() {
            _houseType = newValue;
          });
        }
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
          onPressed: showSalePriceDialog,
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
                  'Edit Sale Price',
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
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _updateProperty() {
    // Combine existing and new photos
    final allPhotoPaths = [
      ..._existingPhotos.where((photo) => !_photosToDelete.contains(photo)),
      ..._selectedPhotos.map((x) => x.path),
    ];

    // Create updated PropertyModel
    final updatedProperty = PropertyModel(
      id: widget.property.id, // Keep original ID
      propertyType: _propertyType,
      location: _location,
      description: _descriptionController.text,
      price: (price ?? int.tryParse(_priceController.text) ?? 0).toDouble(),
      currency: _currency,
      bedrooms: int.tryParse(_bedroomsController.text) ?? 0,
      baths: int.tryParse(_bathsController.text) ?? 0,
      sqft: int.tryParse(_sqftController.text)?.toDouble() ?? 0,
      units: int.tryParse(_unitsController.text) ?? 0,
      isActive: _isActive,
      pendingReason: _isActive ? "" : _pendingReasonController.text,
      isRent: _isRentSelected,
      isSale: _isSaleSelected,
      enteredSalePrice: (salePrice ?? 0).toDouble(),
      saleConditions: salesCondition,
      hasParking: _hasParking,
      isFurnished: _isFurnished,
      hasAC: _hasAC,
      hasInternet: _hasInternet,
      hasCompound: _hasCompound,
      hasSecurity: _hasSecurity,
      isPetFriendly: _isPetFriendly,
      amenities: _amenities,
      productIMG: allPhotoPaths.isNotEmpty ? allPhotoPaths.first : "",
      photoPaths: allPhotoPaths,
      videoPath: _selectedVideo?.path ?? widget.property.videoPath,
      starRating: widget.property.starRating, // Keep existing rating
      reviews: widget.property.reviews, // Keep existing reviews
      uploaderName: widget.property.uploaderName,
      uploaderEmail: widget.property.uploaderEmail,
      uploaderIMG: widget.property.uploaderIMG,
      uploaderPhoneNumber: widget.property.uploaderPhoneNumber,
      insideViews: allPhotoPaths,
      thumbnail: _thumbnailPhoto?.path ?? widget.property.thumbnail ?? "",
      discount: (discount ?? 0).toDouble(),
      destinationTitle: _houseType,
      commission: (commission ?? 0).toDouble(),
      package: selectedPackage,
      dateCreated: widget.property.dateCreated,
      rulesDocumentPath:
          _rulesDocument?.path ?? widget.property.rulesDocumentPath,
      numberOfMonths: '',
      isLand: false,
      userId: null,
      listingType: '',
      status: '', // Keep original creation date
      // dateUpdated: DateTime.now(), // Add update timestamp
    );

    // Update in Riverpod state
    final currentProducts = ref.read(productProvider);
    final updatedProducts =
        currentProducts
            .map((p) => p.id == updatedProperty.id ? updatedProperty : p)
            .toList();
    for (final p in updatedProducts) {
      ref.read(productProvider.notifier).updateProduct(p);
    }

    // Also update PostData if needed
    ref
        .read(postDataProvider.notifier)
        .update(
          PostData(
            propertyType: _propertyType,
            location: _location,
            price: price ?? int.tryParse(_priceController.text),
            salePrice: salePrice ?? int.tryParse(_salePriceController.text),
            saleConditions: salesCondition,
            discount: discount,
            videoPath: _selectedVideo?.path,
            commission: commission,
            currency: _currency,
            bedrooms: int.tryParse(_bedroomsController.text) ?? 0,
            baths: int.tryParse(_bathsController.text) ?? 0,
            sqft: int.tryParse(_sqftController.text) ?? 0,
            units: int.tryParse(_unitsController.text) ?? 0,
            isActive: _isActive,
            pendingReason: _isActive ? null : _pendingReasonController.text,
            isRent: _isRentSelected,
            isSale: _isSaleSelected,
            hasParking: _hasParking,
            isFurnished: _isFurnished,
            hasAC: _hasAC,
            hasInternet: _hasInternet,
            hasSecurity: _hasSecurity,
            isPetFriendly: _isPetFriendly,
            description: _descriptionController.text,
            photoPaths: allPhotoPaths,
            rulesDocumentPath: _rulesDocument?.path,
            isLand: false,
          ),
        );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Property updated successfully!")),
    );

    Navigator.pop(context);
  }

  Widget _buildExistingPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Existing Photos'),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _existingPhotos.length,
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
                        image:
                            _existingPhotos[index].startsWith('http')
                                ? NetworkImage(_existingPhotos[index])
                                : FileImage(File(_existingPhotos[index]))
                                    as ImageProvider,
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
                          _photosToDelete.add(_existingPhotos[index]);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              _photosToDelete.contains(_existingPhotos[index])
                                  ? Colors.red
                                  : Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _photosToDelete.contains(_existingPhotos[index])
                              ? Icons.delete_forever
                              : Icons.delete,
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
        if (_photosToDelete.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${_photosToDelete.length} photo(s) marked for deletion',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _pickPhotos() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        // Calculate total photos including existing ones not marked for deletion
        final remainingExisting =
            _existingPhotos
                .where((photo) => !_photosToDelete.contains(photo))
                .length;
        final availableSlots = 10 - remainingExisting;

        if (_selectedPhotos.length + pickedFiles.length <= availableSlots) {
          _selectedPhotos.addAll(pickedFiles);
        } else {
          final remainingSlots = availableSlots - _selectedPhotos.length;
          if (remainingSlots > 0) {
            _selectedPhotos.addAll(pickedFiles.take(remainingSlots));
          }
        }
      });
    }
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updateProperty,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Update Property',
          style: TextStyle(
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
    // Ensure the current value is in the list
    String currentValue = _propertyType;
    if (!propertyTypes.contains(currentValue)) {
      currentValue = propertyTypes.first;
      _propertyType = currentValue;
    }

    return DropdownButtonFormField<String>(
      value: currentValue,
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
        if (newValue != null) {
          setState(() {
            _propertyType = newValue;
          });
        }
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
                  controller: _pendingReasonController,
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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

        _saveLocationData(position.latitude, position.longitude, address);
      }
    } catch (e) {
      _showError("Error getting location: $e");
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _openMapPicker() {
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
    print("Location selected: $address ($lat, $lng)");
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
                    'Add more photos',
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
                  Text(
                    widget.property.videoPath != null &&
                            widget.property.videoPath!.isNotEmpty
                        ? 'Replace video'
                        : 'Add a short video',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_selectedVideo != null ||
            (widget.property.videoPath != null &&
                widget.property.videoPath!.isNotEmpty))
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
                        (widget.property.thumbnail == null ||
                            widget.property.thumbnail!.isEmpty)
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
                                  : widget.property.thumbnail!.startsWith(
                                    'http',
                                  )
                                  ? Image.network(
                                    widget.property.thumbnail!,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.file(
                                    File(widget.property.thumbnail!),
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
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

  Future<void> _pickNewDocument(BuildContext context) async {
    try {
      final picker = ImagePicker();

      final XFile? file = await picker.pickMedia(); // supports pdf, doc, image

      if (file != null) {
        setState(() {
          _rulesDocument = file;
        });
      }
    } catch (e) {
      debugPrint("Error picking document: $e");
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 30),
    );

    if (pickedFile != null) {
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
}
