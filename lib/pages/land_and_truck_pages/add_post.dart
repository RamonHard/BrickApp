import 'dart:io';

import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final style = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextColor,
  );
  final List<String> packages = ['1 Month', '2 Months', '3 Months'];
  String? selectedPackage;
  int? price;
  int? discount;
  int? commission;

  final currencyFormatter = NumberFormat("#,##0", "en_US"); // Format UGX nicely

  void showPriceDialog(String pkg) {
    final priceController = TextEditingController(
      text: price?.toString() ?? '600000',
    );

    int dialogDiscount = discount ?? 30000; // default 5% of 600,000
    int dialogCommission = commission ?? 18000; // default 3% of 600,000

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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close,
                          color: const Color.fromARGB(255, 197, 13, 0),
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
                        decoration: InputDecoration(labelText: 'Enter Price'),
                        onChanged: (value) {
                          final enteredPrice = int.tryParse(value) ?? 0;
                          setStateDialog(() {
                            dialogDiscount = (enteredPrice * 0.05).toInt();
                            dialogCommission = (enteredPrice * 0.03).toInt();
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Selected Package: $pkg',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                      SizedBox(height: 8),
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
                      child: Text('Done'),
                    ),
                  ],
                ),
          ),
    );
  }

  // Package List View Widget
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

  // Selected Package Info Widget
  Widget buildSelectedInfo() {
    if (selectedPackage == null) return SizedBox();

    return Card(
      margin: EdgeInsets.only(top: 16),
      elevation: 20,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Package: $selectedPackage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Price: UGX${currencyFormatter.format(price ?? 0)}'),
            Text('Discount: UGX${currencyFormatter.format(discount ?? 0)}'),
            Text('Commission: UGX${currencyFormatter.format(commission ?? 0)}'),
          ],
        ),
      ),
    );
  }

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

  String _currency = 'USD';
  String _propertyType = 'House'; // Fixed case
  String _location = 'Kampala';

  bool _hasParking = false;
  bool _isFurnished = false;
  bool _hasAC = false;
  bool _hasInternet = false;
  bool _hasSecurity = false;
  bool _isPetFriendly = false;
  int _photosCount = 0;

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
              _buildSectionTitle('Location'),
              _buildLocationDropdown(),
              const SizedBox(height: 20),
              _buildSectionTitle('Set Rental Price Package'),
              //Package List View Goes Here
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: packages.map(buildPackageCard).toList(),
                ),
              ),
              SizedBox(height: 10),
              //Selected Package Container goes Here
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

              _buildSectionTitle('Description'),
              _buildDescriptionField(),
              const SizedBox(height: 20),

              _buildSectionTitle('Add Photos'),
              _buildPhotosSection(),
              const SizedBox(height: 30),

              _buildPostButton(),
              const SizedBox(height: 20),
            ],
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

  // Added field for Units
  Widget _buildUnitsField() {
    return Column(
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
        SizedBox(
          height: 35,
          width: 150,
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
              hintText: 'Number of rental units',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    List<String> locations = [
      'Kampala',
      'Entebbe',
      'Wakiso',
      'Luzira',
      'Bugolobi',
    ];

    return DropdownButtonFormField<String>(
      value: _location,
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
        prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
      ),
      items:
          locations.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: (newValue) {
        setState(() {
          _location = newValue!;
        });
      },
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
        _buildAmenityItem(Icons.ac_unit, 'Air Conditioning', _hasAC, (val) {
          setState(() => _hasAC = val);
        }),
        _buildAmenityItem(Icons.wifi, 'Internet', _hasInternet, (val) {
          setState(() => _hasInternet = val);
        }),
        _buildAmenityItem(Icons.security, 'Security', _hasSecurity, (val) {
          setState(() => _hasSecurity = val);
        }),
        _buildAmenityItem(Icons.grass, 'Big Compound', _isPetFriendly, (val) {
          setState(() => _isPetFriendly = val);
        }),
      ],
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

  List<XFile> _selectedPhotos = [];

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
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

  @override
  void dispose() {
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathsController.dispose();
    _sqftController.dispose();
    _unitsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

//FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
