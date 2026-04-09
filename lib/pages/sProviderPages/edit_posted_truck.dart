// pages/edit_truck_page.dart
import 'dart:io';
import 'dart:convert';
import 'package:brickapp/models/truck_driver_model.dart';
import 'package:brickapp/providers/truck_driver_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Add this for MediaType

class EditTruckPage extends ConsumerStatefulWidget {
  final Truck truck;

  const EditTruckPage({Key? key, required this.truck}) : super(key: key);

  @override
  ConsumerState<EditTruckPage> createState() => _EditTruckPageState();
}

class _EditTruckPageState extends ConsumerState<EditTruckPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isUpdating = false;

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
  String? existingPhotoUrl;

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
    existingPhotoUrl = widget.truck.photoUrl;

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
        existingPhotoUrl =
            null; // Clear existing photo when new one is selected
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });

      try {
        final token = ref.read(userProvider).token;

        if (token == null) {
          throw Exception('You must be logged in');
        }

        final fullPhone = '+256${phoneController.text}';
        final priceValue = vehiclePricing[selectedVehicleType]!;

        // Create multipart request for potential photo upload
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse('${AppUrls.baseUrl}/vehicles/${widget.truck.id}'),
        );

        request.headers.addAll({'Authorization': 'Bearer $token'});

        // Add text fields
        request.fields['truck_model'] = truckModelController.text;
        request.fields['license_plate'] = licensePlateController.text;
        request.fields['vehicle_type'] = selectedVehicleType;
        request.fields['capacity'] = capacityController.text;
        request.fields['price_per_km'] = priceValue.toString();
        request.fields['phone'] = fullPhone;
        request.fields['email'] = emailController.text;

        // Add new photo if selected
        if (truckPhoto != null) {
          final extension = truckPhoto!.path.split('.').last.toLowerCase();
          String mimeType;
          switch (extension) {
            case 'jpg':
            case 'jpeg':
              mimeType = 'image/jpeg';
              break;
            case 'png':
              mimeType = 'image/png';
              break;
            default:
              mimeType = 'image/jpeg';
          }

          var photoFile = await http.MultipartFile.fromPath(
            'photo',
            truckPhoto!.path,
            contentType: MediaType.parse(mimeType),
          );
          request.files.add(photoFile);
        }

        // Send request
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print('Update response status: ${response.statusCode}');
        print('Update response body: $responseBody');

        setState(() {
          _isUpdating = false;
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          final updatedVehicle = data['vehicle'];

          // Create updated truck object
          final updatedTruck = Truck(
            id: updatedVehicle['id'].toString(),
            truckModel: updatedVehicle['brand'] ?? '',
            licensePlate: updatedVehicle['plate_number'] ?? '',
            vehicleType: selectedVehicleType,
            capacity:
                updatedVehicle['capacity']?.toString() ??
                capacityController.text,
            pricePerKm: priceValue.toDouble(),
            phone: fullPhone,
            email: emailController.text,
            photo: truckPhoto,
            photoUrl: updatedVehicle['photo_url'],
            createdAt: DateTime.parse(updatedVehicle['created_at']),
            ownerId: updatedVehicle['user_id'].toString(),
            isAvailable: updatedVehicle['is_available'] ?? true,
          );

          // Update in Riverpod state
          ref
              .read(truckProvider.notifier)
              .updateTruck(widget.truck.id, updatedTruck);

          _showSuccessDialog();
        } else {
          final data = jsonDecode(responseBody);
          _showErrorDialog(data['message'] ?? 'Failed to update truck');
        }
      } catch (e) {
        setState(() {
          _isUpdating = false;
        });
        _showErrorDialog('Error: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Success',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text('Truck details updated successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Error',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                  padding: const EdgeInsets.all(6),
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 12),
            _buildPhotoPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    // Determine which image to show
    Widget imageWidget;

    if (truckPhoto != null) {
      imageWidget = Image.file(truckPhoto!, fit: BoxFit.cover);
    } else if (existingPhotoUrl != null && existingPhotoUrl!.isNotEmpty) {
      imageWidget = Image.network(
        '${AppUrls.baseUrl}${existingPhotoUrl!}',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      );
    } else {
      imageWidget = const Icon(
        Icons.local_shipping,
        size: 50,
        color: Colors.grey,
      );
    }

    return Column(
      children: [
        (truckPhoto != null || existingPhotoUrl != null)
            ? Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageWidget,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        truckPhoto = null;
                        existingPhotoUrl = null;
                      });
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black54,
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
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
                icon: const Icon(Icons.camera_alt, size: 20),
                label: Text('Take New Photo', style: GoogleFonts.poppins()),
                onPressed: () => _pickImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library, size: 20),
                label: Text('From Gallery', style: GoogleFonts.poppins()),
                onPressed: () => _pickImage(ImageSource.gallery),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
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

  // Reuse all the other UI methods from your existing code...
  // _buildBasicDetailsSection, _buildPricingSection, etc. remain the same

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
                  padding: const EdgeInsets.all(6),
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 12),
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
                  padding: const EdgeInsets.all(6),
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 12),
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
                        const SizedBox(width: 8),
                        Text(
                          'Pricing Information',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'UGX ${vehiclePricing[selectedVehicleType]!.toStringAsFixed(0)} per Km',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.iconColor,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                  padding: const EdgeInsets.all(6),
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 12),
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
                  padding: const EdgeInsets.all(6),
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 12),
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
        onPressed: _isUpdating ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.iconColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            _isUpdating
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.update, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
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
