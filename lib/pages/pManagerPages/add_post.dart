import 'dart:io';
import 'package:brickapp/models/add_post_model.dart';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/pManagerPages/map_location_picker_page.dart';
import 'package:brickapp/providers/post_data_notifier.dart';
import 'package:brickapp/providers/product_providers.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class AddPost extends ConsumerStatefulWidget {
  const AddPost({super.key});

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
  bool _isLoadingLocation = false;
  List<XFile> _selectedVideos = [];
  XFile? _selectedVideo;
  bool _isVideo = false;
  final List<String> packages = ['1 Month', '2 Months', '3 Months'];
  String? selectedPackage;
  int? price;
  int? discount;
  int? commission;
  XFile? _thumbnailPhoto;

  final currencyFormatter = NumberFormat("#,##0", "en_US");

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
                        'Set Price',
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
                      child: const Text('Done'),
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
    if (selectedPackage == null) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 20,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Package: $selectedPackage',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Price: UGX${currencyFormatter.format(price ?? 0)}'),
            Text('Discount: UGX${currencyFormatter.format(discount ?? 0)}'),
            Text('Commission: UGX${currencyFormatter.format(commission ?? 0)}'),
          ],
        ),
      ),
    );
  }

  // Controllers
  final TextEditingController _priceController = TextEditingController(
    text: '20',
  );
  final TextEditingController _bedroomsController = TextEditingController(
    text: '3',
  );
  final TextEditingController _bathsController = TextEditingController(
    text: '2',
  );
  final TextEditingController _sqftController = TextEditingController(
    text: '1200',
  );
  final TextEditingController _unitsController = TextEditingController(
    text: '1',
  );
  final TextEditingController _descriptionController = TextEditingController(
    text: 'e.g Three bed rooms, Parking space, Self contained,',
  );
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
          'Post Your Rental',
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

              _buildSectionTitle('House Type'),
              _buildHouseTypeDropdown(),
              const SizedBox(height: 20),

              _buildSectionTitle('Location'),
              _buildLocationPicker(),
              const SizedBox(height: 20),

              _buildSectionTitle('Set Rental Price Package'),
              showHouseSections
                  ? SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: packages.map(buildPackageCard).toList(),
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
              _buildSectionTitle("Listing Type"),
              const SizedBox(height: 10),
              _buildListingTypeButtons(),
              const SizedBox(height: 20),

              _buildSectionTitle('Description'),
              _buildDescriptionField(),
              const SizedBox(height: 20),

              _buildSectionTitle('Add Photos'),
              _buildPhotosSection(),
              const SizedBox(height: 20),

              _buildSectionTitle('Add Thumbnail'),
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
          onPressed: () => setState(() => _isSaleSelected = !_isSaleSelected),
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

  // Updated _updatePostData method
  void _updatePostData() {
    // Create PropertyModel with ALL fields
    final newProperty = PropertyModel(
      id: DateTime.now().millisecondsSinceEpoch,
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
      hasParking: _hasParking,
      isFurnished: _isFurnished,
      hasAC: _hasAC,
      hasInternet: _hasInternet,
      hasSecurity: _hasSecurity,
      isPetFriendly: _isPetFriendly,
      amenities: _amenities, // Use the computed amenities list
      productIMG: _selectedPhotos.isNotEmpty ? _selectedPhotos.first.path : "",
      photoPaths: _selectedPhotos.map((x) => x.path).toList(),
      videoPath: _selectedVideo?.path,
      starRating: 0.0,
      reviews: 0,
      uploaderName: "Current User", // You should get this from user auth
      uploaderEmail: "me@example.com", // You should get this from user auth
      uploaderIMG:
          "https://i.pravatar.cc/150?img=1", // You should get this from user auth
      uploaderPhoneNumber: 123456789, // You should get this from user auth
      insideViews: _selectedPhotos.map((x) => x.path).toList(),
      thumbnail: _thumbnailPhoto?.path ?? "",
      discount: (discount ?? 0).toDouble(),
      destinationTitle: _propertyType,
      commission: (commission ?? 0).toDouble(), // Added commission
      package: selectedPackage, // Added package
      dateCreated: DateTime.now(), // Added timestamp
    );

    // Update Riverpod state
    ref.read(productProvider.notifier).addProduct(newProperty);

    // Also update PostData if needed
    ref
        .read(postDataProvider.notifier)
        .update(
          PostData(
            propertyType: _propertyType,
            location: _location,
            price: price ?? int.tryParse(_priceController.text),
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
            photoPaths: _selectedPhotos.map((x) => x.path).toList(),
            // package: selectedPackage, // Added package
          ),
        );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Property added successfully!")),
    );

    Navigator.pop(context);
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
        onPressed: _updatePostData, // Simplified call
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Post Rental',
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
    List<String> propertyTypes = [
      'House',
      'Business Shop',
      'Land',
      'Ceremony Ground',
      'Apartments',
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
        _buildAmenityItem(Icons.grass, 'Compound', _isPetFriendly, (val) {
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
                                _location == "Kampala"
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
                _thumbnailPhoto == null
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
                          child: Image.file(
                            File(_thumbnailPhoto!.path),
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
}
