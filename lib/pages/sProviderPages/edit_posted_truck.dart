// pages/edit_truck_page.dart
import 'dart:io';

import 'package:brickapp/models/truck_driver_model.dart';
import 'package:brickapp/providers/truck_driver_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditTruckPage extends ConsumerStatefulWidget {
  final Truck truck;

  const EditTruckPage({Key? key, required this.truck}) : super(key: key);

  @override
  ConsumerState<EditTruckPage> createState() => _EditTruckPageState();
}

class _EditTruckPageState extends ConsumerState<EditTruckPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

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

  late String selectedVehicleType;
  File? truckPhoto;

  // Form controllers
  final TextEditingController truckModelController = TextEditingController();
  final TextEditingController licensePlateController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize form with existing truck data
    selectedVehicleType = widget.truck.vehicleType;
    truckPhoto = widget.truck.photo;

    truckModelController.text = widget.truck.truckModel;
    licensePlateController.text = widget.truck.licensePlate;
    capacityController.text = widget.truck.capacity;
    emailController.text = widget.truck.email;

    // Extract phone number without country code for editing
    final phone = widget.truck.phone;
    if (phone.startsWith('+256')) {
      phoneController.text = phone.substring(4);
    } else {
      phoneController.text = phone;
    }
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final fullPhone = '+256${phoneController.text}';

      // Create updated truck instance
      final updatedTruck = widget.truck.copyWith(
        truckModel: truckModelController.text,
        licensePlate: licensePlateController.text,
        vehicleType: selectedVehicleType,
        capacity: capacityController.text,
        pricePerKm: vehiclePricing[selectedVehicleType]!,
        phone: fullPhone,
        email: emailController.text,
        photo: truckPhoto,
      );

      // Update in Riverpod state
      ref
          .read(truckProvider.notifier)
          .updateTruck(widget.truck.id, updatedTruck);

      // Show success dialog and go back
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
          content: Text('Truck details updated successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                MainNavigation.navigateToRoute(
                  MainNavigation.myTrucksListRoute,
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Truck Details',
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
                _buildPhotoSection(),
                const SizedBox(height: 24),
                _buildBasicDetailsSection(),
                const SizedBox(height: 20),
                _buildPricingSection(),
                const SizedBox(height: 20),
                _buildCapacitySection(),
                const SizedBox(height: 20),
                _buildContactSection(),
                const SizedBox(height: 30),
                _buildUpdateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reuse the same UI components from PostTruckPage but with existing data
  Widget _buildPhotoSection() {
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
                  child: Icon(
                    Icons.photo_library,
                    size: 18,
                    color: AppColors.iconColor,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Vehicle Photo',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildPhotoPicker(),
          ],
        ),
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
                    onTap: () {
                      setState(() {
                        truckPhoto = null;
                      });
                    },
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
                    'Current Truck Photo\nTap below to change',
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
                label: Text('Take New Photo', style: GoogleFonts.poppins()),
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

  Widget _buildBasicDetailsSection() {
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
                  child: Icon(
                    Icons.local_shipping,
                    size: 18,
                    color: AppColors.iconColor,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Basic Details',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
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
                  selectedVehicleType = value!;
                });
              },
              icon: Icons.category,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
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
                  child: Icon(
                    Icons.attach_money,
                    size: 18,
                    color: AppColors.iconColor,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Pricing Details',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
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
                      'UGX ${vehiclePricing[selectedVehicleType]!.toStringAsFixed(0)} per Km',
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
          ],
        ),
      ),
    );
  }

  Widget _buildCapacitySection() {
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
                  child: Icon(
                    Icons.inventory,
                    size: 18,
                    color: AppColors.iconColor,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Capacity Details',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: capacityController,
              label: 'Load Capacity (Tons)',
              hint: 'e.g. 5, 10, 15',
              icon: Icons.scale,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
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
                  child: Icon(
                    Icons.contact_phone,
                    size: 18,
                    color: AppColors.iconColor,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildPhoneNumberField(),
            _buildTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'Enter email address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
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
    required String value,
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

  Widget _buildPhoneNumberField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 130,
            child: DropdownButtonFormField<String>(
              value: '+256',
              items:
                  ['+256', '+255', '+254', '+250'].map((code) {
                    return DropdownMenuItem(value: code, child: Text(code));
                  }).toList(),
              onChanged: (value) {
                // Handle country code change if needed
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

  Widget _buildUpdateButton() {
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
            Icon(Icons.update, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Update Truck Details',
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

  @override
  void dispose() {
    truckModelController.dispose();
    licensePlateController.dispose();
    capacityController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
