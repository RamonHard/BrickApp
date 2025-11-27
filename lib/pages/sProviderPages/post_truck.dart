import 'dart:io';
import 'package:brickapp/models/truck_driver_model.dart';
import 'package:brickapp/providers/truck_driver_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class PostTruckPage extends ConsumerStatefulWidget {
  const PostTruckPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PostTruckPage> createState() => _PostTruckPageState();
}

class _PostTruckPageState extends ConsumerState<PostTruckPage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> vehicleTypes = [
    'Small Truck',
    'Medium Truck',
    'Large Truck',
    'Trailer',
  ];

  final Map<String, int> vehiclePricing = {
    'Small Truck': 50000,
    'Medium Truck': 100000,
    'Large Truck': 150000,
    'Trailer': 200000,
  };

  String? selectedVehicleType;
  File? truckPhoto;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final TextEditingController truckModelController = TextEditingController();
  final TextEditingController licensePlateController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Phone related
  String selectedCountryCode = '+256';
  final TextEditingController phoneController = TextEditingController();

  // Pricing display
  String get pricingInfo {
    if (selectedVehicleType == null)
      return 'Select vehicle type to see pricing';
    final price = vehiclePricing[selectedVehicleType]!;
    return 'UGX ${price.toStringAsFixed(0)} per Km';
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 75,
    );
    if (pickedFile != null) {
      setState(() {
        truckPhoto = File(pickedFile.path);
      });
    }
  }

  void _removePhoto() {
    setState(() {
      truckPhoto = null;
    });
  }

  // Update the _submitForm method in PostTruckPage
  void _submitForm() {
    if (_formKey.currentState!.validate() && selectedVehicleType != null) {
      final fullPhone = '$selectedCountryCode${phoneController.text}';
      final currentUserId = ref.read(currentUserIdProvider);

      // Create a new truck instance
      final newTruck = Truck(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        truckModel: truckModelController.text,
        licensePlate: licensePlateController.text,
        vehicleType: selectedVehicleType!,
        capacity: capacityController.text,
        pricePerKm: vehiclePricing[selectedVehicleType]!,
        phone: fullPhone,
        email: emailController.text,
        photo: truckPhoto,
        createdAt: DateTime.now(),
        ownerId: currentUserId, // Set the owner ID
        isAvailable: true,
      );

      // Add to Riverpod state
      ref.read(truckProvider.notifier).addTruck(newTruck);

      // Show success dialog
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text('Success', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('Your truck has been posted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
                // Optionally navigate to trucks list
                // Navigator.push(context, MaterialPageRoute(builder: (context) => TrucksListPage()));
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    truckModelController.clear();
    licensePlateController.clear();
    capacityController.clear();
    phoneController.clear();
    emailController.clear();
    setState(() {
      selectedVehicleType = null;
      truckPhoto = null;
    });
  }

  @override
  void dispose() {
    truckModelController.dispose();
    licensePlateController.dispose();
    capacityController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Your Truck',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.iconColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.iconColor.withOpacity(0.1),
              Colors.grey.shade100,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),

                _buildBasicDetailsSection(),
                const SizedBox(height: 20),

                _buildPricingSection(),
                const SizedBox(height: 20),

                _buildCapacitySection(),
                const SizedBox(height: 20),

                _buildPhotoSection(),
                const SizedBox(height: 20),

                _buildContactSection(),
                const SizedBox(height: 30),

                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppColors.iconColor, AppColors.iconColor.withOpacity(0.8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Post Your Truck',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Get deals quickly and efficiently through our platform. Fill in the details below to get started.',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicDetailsSection() {
    return _buildSection(
      title: 'Basic Details',
      icon: Icons.local_shipping,
      children: [
        _buildTextField(
          controller: truckModelController,
          label: 'Truck Model',
          hint: 'e.g. Ford F-150, Toyota Hilux',
          icon: Icons.directions_car,
        ),
        _buildTextField(
          controller: licensePlateController,
          label: 'License Plate',
          hint: 'Enter license plate number',
          icon: Icons.confirmation_number,
        ),
        _buildDropdownField(
          label: 'Vehicle Type',
          value: selectedVehicleType,
          items: vehicleTypes,
          onChanged: (value) {
            setState(() {
              selectedVehicleType = value;
            });
          },
          icon: Icons.category,
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return _buildSection(
      title: 'Pricing Details',
      icon: Icons.attach_money,
      children: [
        Card(
          elevation: 2,
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Pricing Information',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  pricingInfo,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.iconColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Price is automatically set based on vehicle type',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        _buildPricingTable(),
      ],
    );
  }

  Widget _buildPricingTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children:
            vehicleTypes.map((type) {
              final isSelected = selectedVehicleType == type;
              return Container(
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.iconColor.withOpacity(0.1)
                          : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    _getVehicleIcon(type),
                    color: isSelected ? AppColors.iconColor : Colors.grey,
                  ),
                  title: Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.iconColor : Colors.black,
                    ),
                  ),
                  trailing: Text(
                    'UGX ${vehiclePricing[type]!.toStringAsFixed(0)}/Km',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.iconColor,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type) {
      case 'Small Truck':
        return Icons.local_shipping;
      case 'Medium Truck':
        return Icons.fire_truck;
      case 'Large Truck':
        return Icons.airport_shuttle;
      case 'Trailer':
        return Icons.rv_hookup;
      default:
        return Icons.local_shipping;
    }
  }

  Widget _buildCapacitySection() {
    return _buildSection(
      title: 'Capacity Details',
      icon: Icons.inventory,
      children: [
        _buildTextField(
          controller: capacityController,
          label: 'Load Capacity (Tons)',
          hint: 'e.g. 5, 10, 15',
          icon: Icons.scale,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return _buildSection(
      title: 'Vehicle Photos',
      icon: Icons.photo_library,
      children: [
        Text(
          'Add clear photos of your truck from different angles',
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
        ),
        SizedBox(height: 12),
        _buildPhotoPicker(),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      children: [
        _buildPhoneNumberField(),
        _buildTextField(
          controller: emailController,
          label: 'Email Address',
          hint: 'Enter email address',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: AppColors.iconColor),
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.iconColor, width: 2),
          ),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.iconColor, width: 2),
          ),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Please select' : null,
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Column(
      children: [
        truckPhoto != null
            ? Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(truckPhoto!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: _removePhoto,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
            : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Truck Photo\nPNG, JPG up to 10MB',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.camera_alt, size: 20),
                label: Text('Take Photo', style: GoogleFonts.poppins()),
                onPressed: () => _pickImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Icons.photo_library, size: 20),
                label: Text('From Gallery', style: GoogleFonts.poppins()),
                onPressed: () => _pickImage(ImageSource.gallery),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 140,
            child: DropdownButtonFormField<String>(
              value: selectedCountryCode,
              items:
                  ['+256', '+255', '+254', '+250'].map((code) {
                    return DropdownMenuItem(value: code, child: Text(code));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCountryCode = value!;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.flag, color: AppColors.iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone, color: AppColors.iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.iconColor, width: 2),
                ),
              ),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.iconColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Post Truck',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
