import 'dart:io';
import 'dart:ui';
import 'package:brickapp/models/user_model.dart';
import 'package:brickapp/providers/account_type_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class RegisterTruckerDriver extends ConsumerStatefulWidget {
  const RegisterTruckerDriver({super.key});

  @override
  ConsumerState<RegisterTruckerDriver> createState() =>
      _RegisterTruckerDriverState();
}

class _RegisterTruckerDriverState extends ConsumerState<RegisterTruckerDriver> {
  TextStyle style = GoogleFonts.actor(
    fontSize: 16,
    color: HexColor("FFFFFF"),
    fontWeight: FontWeight.w600,
  );

  final double _sigmax = 0.0;
  final double _sigmay = 0.0;
  final double _opacity = 0.1;
  double sizedbox = 20.0;

  int? selectedValue;

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumController = TextEditingController();
  TextEditingController idNINController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController driverPermitController = TextEditingController();

  File? _idFrontPhoto;
  File? _idBackPhoto;
  File? _facePhoto;
  File? _driverPermitPhoto;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.iconColor,
              size: 35,
            ),
          ),
          title: Text(
            'Transport Manager Registration',
            style: GoogleFonts.actor(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/brickwall.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _sigmax, sigmaY: _sigmay),
                child: Container(color: Colors.black.withOpacity(_opacity)),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),

                  // Personal Information
                  Text("Full Name", style: style),
                  SizedBox(height: 8),
                  _buildTextField(fullNameController, "Enter your full name"),

                  SizedBox(height: sizedbox),
                  Text("Business Email (Optional)", style: style),
                  SizedBox(height: 8),
                  _buildTextField(
                    emailController,
                    "Enter business email",
                    TextInputType.emailAddress,
                  ),

                  SizedBox(height: sizedbox),
                  Text("Business Phone Number", style: style),
                  SizedBox(height: 8),
                  _buildTextField(
                    phoneNumController,
                    "Enter phone number",
                    TextInputType.phone,
                  ),

                  SizedBox(height: sizedbox),
                  Text("National ID Number", style: style),
                  SizedBox(height: 8),
                  _buildTextField(idNINController, "Enter NIN or ID number"),

                  SizedBox(height: sizedbox),
                  Text("Driver's Permit Number", style: style),
                  SizedBox(height: 8),
                  _buildTextField(
                    driverPermitController,
                    "Enter permit number",
                  ),

                  SizedBox(height: sizedbox),
                  Text("Physical Address", style: style),
                  SizedBox(height: 8),
                  _buildTextField(addressController, "Enter your address"),

                  SizedBox(height: sizedbox),

                  // ID Photos
                  Text("Upload ID Photos", style: style),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPhotoUpload(
                          "Front Side",
                          _idFrontPhoto,
                          () => _pickImage('id_front'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildPhotoUpload(
                          "Back Side",
                          _idBackPhoto,
                          () => _pickImage('id_back'),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: sizedbox),

                  // Driver's Permit Photo
                  Text("Upload Driver's Permit", style: style),
                  SizedBox(height: 8),
                  _buildPhotoUpload(
                    "Permit Photo",
                    _driverPermitPhoto,
                    () => _pickImage('permit'),
                  ),

                  SizedBox(height: sizedbox),

                  // Face Photo
                  Text("Upload Passport Photo", style: style),
                  SizedBox(height: 8),
                  _buildPhotoUpload(
                    "Face Photo",
                    _facePhoto,
                    () => _pickImage('face'),
                  ),

                  SizedBox(height: sizedbox),

                  // Gender Selection
                  Text("Gender", style: style),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          activeColor: AppColors.iconColor,
                          title: Text(
                            "Male",
                            style: GoogleFonts.oxygen(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: HexColor("FFFFFF"),
                            ),
                          ),
                          value: 1,
                          groupValue: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          activeColor: AppColors.iconColor,
                          title: Text(
                            "Female",
                            style: GoogleFonts.oxygen(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: HexColor("FFFFFF"),
                            ),
                          ),
                          value: 2,
                          groupValue: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40),

                  // Submit Button
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: MaterialButton(
                      minWidth: 200,
                      height: 50,
                      onPressed: _validateAndSubmit,
                      color: AppColors.buttonColor,
                      padding: const EdgeInsets.all(8.0),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      child: const Text(
                        'Submit Application',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, [
    TextInputType? keyboardType,
  ]) {
    return Container(
      height: 50,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white54),
          filled: false,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(100),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload(String label, File? file, VoidCallback onTap) {
    return Column(
      children: [
        Text(label, style: style.copyWith(fontSize: 14)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.transparent,
            ),
            child:
                file == null
                    ? Icon(
                      Icons.add_a_photo_outlined,
                      color: Colors.white,
                      size: 40,
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file, fit: BoxFit.cover),
                    ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        switch (type) {
          case 'id_front':
            _idFrontPhoto = File(image.path);
            break;
          case 'id_back':
            _idBackPhoto = File(image.path);
            break;
          case 'permit':
            _driverPermitPhoto = File(image.path);
            break;
          case 'face':
            _facePhoto = File(image.path);
            break;
        }
      });
    }
  }

  void _validateAndSubmit() {
    if (fullNameController.text.isEmpty ||
        phoneNumController.text.isEmpty ||
        idNINController.text.isEmpty ||
        driverPermitController.text.isEmpty ||
        _idFrontPhoto == null ||
        _idBackPhoto == null ||
        _driverPermitPhoto == null ||
        _facePhoto == null ||
        selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all required fields and upload all photos',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Before updating user provider');
    print('Current user state: ${ref.read(userProvider).toMap()}');

    // Use the dedicated method
    ref
        .read(userProvider.notifier)
        .setTransportManagerData(
          fullName: fullNameController.text,
          phoneNumber: phoneNumController.text,
          idNumber: idNINController.text,
          driverPermitNumber: driverPermitController.text,
          address: addressController.text,
          gender: selectedValue == 1 ? 'Male' : 'Female',
          email: emailController.text.isEmpty ? null : emailController.text,
          idFrontPhoto: _idFrontPhoto!.path,
          idBackPhoto: _idBackPhoto!.path,
          facePhoto: _facePhoto!.path,
          driverPermitPhoto: _driverPermitPhoto!.path,
        );

    print('After updating user provider');
    print('Updated user state: ${ref.read(userProvider).toMap()}');
    print('Account type: ${ref.read(userProvider).accountType}');
    ref
        .read(accountTypeProvider.notifier)
        .setAccountType(AccountType.transportServiceProvider);
    showActivationPopup();
  }

  void showActivationPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Application Submitted",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Your Transport Manager application has been submitted for review. "
            "You will be notified within 3 working days once your account is activated.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                MainNavigation.navigateToRoute(
                  MainNavigation.clientprofilePageRoute,
                );
              },
              child: const Text("OK", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneNumController.dispose();
    idNINController.dispose();
    addressController.dispose();
    driverPermitController.dispose();
    super.dispose();
  }
}
