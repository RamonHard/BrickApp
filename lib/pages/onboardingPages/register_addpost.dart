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

class PropertyManagerRegistration extends ConsumerStatefulWidget {
  const PropertyManagerRegistration({super.key});

  @override
  ConsumerState<PropertyManagerRegistration> createState() =>
      _PropertyManagerRegistrationState();
}

class _PropertyManagerRegistrationState
    extends ConsumerState<PropertyManagerRegistration> {
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
  Color activeColor = AppColors.iconColor;
  Color disabledColor = AppColors.textColor;

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumController = TextEditingController();
  TextEditingController idNINController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();

  File? _idFrontPhoto;
  File? _idBackPhoto;
  File? _facePhoto;

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
            'Property Manager Registration',
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

                  // Header
                  Container(
                    padding: const EdgeInsets.only(bottom: 30),
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Start Posting Property Content',
                      style: GoogleFonts.actor(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Business Information
                  Text("Business/Company Name", style: style),
                  SizedBox(height: 8),
                  _buildTextField(
                    businessNameController,
                    "Enter business name",
                  ),

                  SizedBox(height: sizedbox),
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
                  _buildPhoneNumberField(),

                  SizedBox(height: sizedbox),
                  Text("National ID Number (NIN)", style: style),
                  SizedBox(height: 8),
                  _buildTextField(idNINController, "Enter NIN number"),

                  SizedBox(height: sizedbox),
                  Text("Physical Business Address", style: style),
                  SizedBox(height: 8),
                  _buildTextField(
                    addressController,
                    "Enter business address",
                    TextInputType.streetAddress,
                  ),

                  SizedBox(height: sizedbox),

                  // ID Photos Section
                  Text("Upload ID Photos", style: style),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPhotoUploadCard(
                          "ID Front Side",
                          _idFrontPhoto,
                          () => _pickImage(true, true),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildPhotoUploadCard(
                          "ID Back Side",
                          _idBackPhoto,
                          () => _pickImage(true, false),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: sizedbox),

                  // Face Photo
                  Text("Upload Passport Photo", style: style),
                  SizedBox(height: 12),
                  _buildPhotoUploadCard(
                    "Face Photo",
                    _facePhoto,
                    () => _pickImage(false, true),
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

                  // Terms Agreement
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.iconColor,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "By submitting, you agree to our terms and conditions for property managers",
                          style: GoogleFonts.actor(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Submit Button
                  Container(
                    padding: const EdgeInsets.only(bottom: 50),
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

  Widget _buildPhoneNumberField() {
    String selectedCountryCode = '+256';

    return Row(
      children: [
        Container(
          width: 100,
          child: DropdownButtonFormField<String>(
            value: selectedCountryCode,
            dropdownColor: Colors.grey[900],
            style: TextStyle(color: Colors.white, fontSize: 16),
            items:
                ['+256', '+255', '+254', '+250', '+1'].map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text(code, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCountryCode = value!;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.flag, color: AppColors.iconColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 50,
            child: TextField(
              controller: phoneNumController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Phone number",
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
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadCard(String label, File? file, VoidCallback onTap) {
    return Column(
      children: [
        Text(
          label,
          style: style.copyWith(fontSize: 14),
          textAlign: TextAlign.center,
        ),
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
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to upload',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file, fit: BoxFit.cover),
                    ),
          ),
        ),
        if (file != null) ...[
          SizedBox(height: 4),
          TextButton(
            onPressed: onTap,
            child: Text(
              'Change Photo',
              style: TextStyle(color: AppColors.iconColor, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage(bool isId, bool isFront) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isId) {
          if (isFront) {
            _idFrontPhoto = File(image.path);
          } else {
            _idBackPhoto = File(image.path);
          }
        } else {
          _facePhoto = File(image.path);
        }
      });
    }
  }

  void _validateAndSubmit() {
    // Basic validation
    if (businessNameController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        phoneNumController.text.isEmpty ||
        idNINController.text.isEmpty ||
        addressController.text.isEmpty ||
        _idFrontPhoto == null ||
        _idBackPhoto == null ||
        _facePhoto == null ||
        selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all required fields and upload all photos',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Store user data in Riverpod provider
    ref.read(userProvider.notifier).setUserData({
      'businessName': businessNameController.text,
      'fullName': fullNameController.text,
      'email': emailController.text.isEmpty ? null : emailController.text,
      'phoneNumber': phoneNumController.text,
      'idNumber': idNINController.text,
      'address': addressController.text,
      'gender': selectedValue == 1 ? 'Male' : 'Female',
      'accountType': AccountType.propertyOwner,
      'idFrontPhoto': _idFrontPhoto!.path,
      'idBackPhoto': _idBackPhoto!.path,
      'facePhoto': _facePhoto!.path,
      // 'registrationDate': DateTime.now(),
      'status': 'pending_review',
    });

    // Update account type
    ref
        .read(accountTypeProvider.notifier)
        .setAccountType(AccountType.propertyOwner);

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
          backgroundColor: Colors.grey[900],
          title: Text(
            "Application Submitted for Review",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          content: Text(
            "Your Property Manager application has been submitted successfully. "
            "Your account will be activated after review within 3 working days. "
            "You'll receive a notification once approved.",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
                MainNavigation.navigateToRoute(
                  MainNavigation.clientprofilePageRoute,
                );
              },
              child: Text(
                "Continue to Profile",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
    businessNameController.dispose();
    super.dispose();
  }
}
