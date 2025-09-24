import 'dart:io';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class PostTruckPage extends StatefulWidget {
  const PostTruckPage({Key? key}) : super(key: key);

  @override
  State<PostTruckPage> createState() => _PostTruckPageState();
}

class _PostTruckPageState extends State<PostTruckPage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> vehicleTypes = [
    'Pickup Truck',
    'Cargo Van',
    'Box Truck',
    'Flatbed Truck',
    'Refrigerated Truck',
  ];

  String? selectedVehicleType;
  File? truckPhoto;
  final ImagePicker _picker = ImagePicker();

  // Phone related
  String selectedCountryCode = '+256';
  final TextEditingController phoneController = TextEditingController();

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

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Your Truck'),
        leading: const BackButton(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle('Basic Details', icon: Icons.local_shipping),
              const SizedBox(height: 8),
              buildTextField(label: 'Truck Model', hint: 'e.g. Ford F-150'),
              buildTextField(
                label: 'License Plate',
                hint: 'Enter license plate number',
              ),
              buildDropdownField(
                label: 'Vehicle Type',
                value: selectedVehicleType,
                items: vehicleTypes,
                onChanged: (value) {
                  setState(() {
                    selectedVehicleType = value;
                  });
                },
              ),

              const SizedBox(height: 24),
              sectionTitle('Pricing Details', icon: Icons.attach_money),
              const SizedBox(height: 8),
              buildDropdownField(
                label: 'Rate Type',
                value: null,
                items: ['Per Mile', 'Per Hour', 'Flat Rate'],
                onChanged: (_) {},
              ),

              buildTextField(
                label: 'Rate Amount (USD)',
                hint: 'Enter amount',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),
              sectionTitle('Vehicle Photo', icon: Icons.camera_alt),
              const SizedBox(height: 8),
              buildSinglePhotoPicker(),

              const SizedBox(height: 24),
              sectionTitle('Contact Details', icon: Icons.contact_phone),
              const SizedBox(height: 8),
              buildPhoneNumberField(),
              buildTextField(
                label: 'Email Address',
                hint: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  height: 40,
                  color: AppColors.iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: Text(
                    'Post Truck',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightTextColor,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final fullPhone =
                          '$selectedCountryCode${phoneController.text}';
                      print('Full phone: $fullPhone');
                      // Submit logic here
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSinglePhotoPicker() {
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
                    child: const CircleAvatar(
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
              padding: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Add a photo of your truck\nPNG, JPG up to 10MB',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Upload'),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPhoneNumberField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          DropdownButton<String>(
            focusColor: AppColors.iconColor,
            value: selectedCountryCode,
            items:
                ['+256'].map((code) {
                  return DropdownMenuItem(value: code, child: Text(code));
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCountryCode = value!;
              });
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 45,
              child: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget buildTextField({
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Please select' : null,
      ),
    );
  }
}
