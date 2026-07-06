import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../utils/app_images.dart' as backImg;
import 'package:flutter/foundation.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _selectedAvatar;
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarName;
  bool _isSubmitting = false;
  bool _showPasswordSection = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user data
    final user = ref.read(userProvider);
    _nameController.text = user.fullName ?? '';
    _phoneController.text = user.phone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
  try {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _selectedAvatarBytes = bytes;
      _selectedAvatarName = picked.name;
    });
  } catch (e) {
    _showSnack(
      'Error picking image: $e',
      Colors.red,
    );
  }
}

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (picked != null) {
        final compressedImage = await _compressImage(File(picked.path));
        setState(() => _selectedAvatar = compressedImage);
      }
    } catch (e) {
      _showSnack('Error taking photo: $e', Colors.red);
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      // Get file size
      final fileSize = await file.length();
      
      // If file is already small enough (< 500KB), return as is
      if (fileSize < 500000) {
        return file;
      }
      
      // If it's larger, we might want to rename it to ensure proper extension
      final extension = path.extension(file.path).toLowerCase();
      if (extension.isEmpty) {
        // Add .jpg extension if missing
        final newPath = '${file.path}.jpg';
        await file.copy(newPath);
        return File(newPath);
      }
      
      return file;
    } catch (e) {
      print('Image compression error: $e');
      return file;
    }
  }

  Future<void> _saveProfile() async {
  // Validate
  if (_nameController.text.trim().isEmpty) {
    _showSnack('Name cannot be empty', Colors.red);
    return;
  }

  if (_phoneController.text.trim().isEmpty) {
    _showSnack('Phone cannot be empty', Colors.red);
    return;
  }

  if (_showPasswordSection) {
    if (_currentPasswordController.text.isEmpty) {
      _showSnack('Enter your current password', Colors.red);
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showSnack('New password must be at least 6 characters', Colors.red);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnack('New passwords do not match', Colors.red);
      return;
    }
  }

  setState(() => _isSubmitting = true);

  try {
    final user = ref.read(userProvider);
    final token = user.token;

    if (token == null || token.isEmpty) {
      _showSnack('Authentication error. Please login again.', Colors.red);
      setState(() => _isSubmitting = false);
      return;
    }

    // Show progress
    _showSnack('Updating profile...', Colors.blue);

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse(AppUrls.editProfile),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Text fields
    request.fields['fullName'] = _nameController.text.trim();
    request.fields['phone'] = _phoneController.text.trim();

    // Password change
    if (_showPasswordSection &&
        _currentPasswordController.text.isNotEmpty) {
      request.fields['currentPassword'] = _currentPasswordController.text;
      request.fields['newPassword'] = _newPasswordController.text;
    }

    // Avatar upload - Fixed implementation
   if (_selectedAvatarBytes != null) {

  final filename =
      _selectedAvatarName ?? 'avatar.jpg';

  final multipartFile =
      http.MultipartFile.fromBytes(
        'avatar',
        _selectedAvatarBytes!,
        filename: filename,
      );

  request.files.add(
    multipartFile,
  );
}

    // Send request with timeout
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('Connection timed out');
      },
    );
    
    final response = await http.Response.fromStream(streamedResponse);
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    setState(() => _isSubmitting = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['status'] == true || data['success'] == true) {
        // Update local user state
        if (data['user'] != null) {
          ref.read(userProvider.notifier).setFromBackend(
            data['user'],
            token,
          );
        } else {
          // If backend doesn't return updated user, update locally
          final updatedUser = user.copyWith(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );
          ref.read(userProvider.notifier).state = updatedUser;
        }

        _showSnack('Profile updated successfully!', Colors.green);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        _showSnack(
          data['message'] ?? data['error'] ?? 'Update failed', 
          Colors.red,
        );
      }
    } else {
      final data = jsonDecode(response.body);
      _showSnack(
        data['message'] ?? data['error'] ?? 'Update failed (${response.statusCode})', 
        Colors.red,
      );
    }
  } on SocketException {
    setState(() => _isSubmitting = false);
    _showSnack('No internet connection. Please check your network.', Colors.red);
  } on TimeoutException {
    setState(() => _isSubmitting = false);
    _showSnack('Connection timed out. Please try again.', Colors.red);
  } catch (e) {
    setState(() => _isSubmitting = false);
    print('Error saving profile: $e');
    _showSnack('Error: ${e.toString()}', Colors.red);
  }
}

  String _getMimeType(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'jpeg';
      case '.png':
        return 'png';
      case '.gif':
        return 'gif';
      case '.webp':
        return 'webp';
      default:
        return 'jpeg';
    }
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            if (_selectedAvatar != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', 
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedAvatar = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;
    final user = ref.watch(userProvider);

    return Container(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.bottomNavColor,
            centerTitle: true,
            title: Text(
              'Edit Profile',
              style: GoogleFonts.actor(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.darkTextColor,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
            ),
          ),
          body: Stack(
            children: [
              // Background
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backImg.AppImages.backImg),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: Container(color: Colors.transparent),
              ),

              // Content
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ─── Avatar ──────────────────────────
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.deepOrange,
                            backgroundImage: _buildAvatarImage(user),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.iconColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white, 
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_selectedAvatar != null) ...[
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'New photo selected ✓',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // ─── Full Name ────────────────────────
                    _buildLabel('Full Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Enter your full name',
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 16),

                    // ─── Phone ────────────────────────────
                    _buildLabel('Phone Number'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '+256 7XX XXX XXX',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 24),

                    // ─── Change Password Toggle ───────────
                    GestureDetector(
                      onTap: () => setState(
                        () => _showPasswordSection = !_showPasswordSection,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: HexColor('FFFFFF').withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _showPasswordSection
                                ? AppColors.iconColor
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock, color: AppColors.iconColor),
                            const SizedBox(width: 12),
                            Text(
                              'Change Password',
                              style: GoogleFonts.actor(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _showPasswordSection
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.iconColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── Password Fields ──────────────────
                    if (_showPasswordSection) ...[
                      const SizedBox(height: 16),
                      _buildLabel('Current Password'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _currentPasswordController,
                        hint: 'Enter current password',
                        icon: Icons.lock_outline,
                        obscure: _obscureCurrent,
                        onToggleObscure: () => setState(
                          () => _obscureCurrent = !_obscureCurrent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('New Password'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _newPasswordController,
                        hint: 'Enter new password',
                        icon: Icons.lock,
                        obscure: _obscureNew,
                        onToggleObscure: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('Confirm New Password'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm new password',
                        icon: Icons.lock,
                        obscure: _obscureConfirm,
                        onToggleObscure: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ─── Save Button ──────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GoogleFonts.actor(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.lightTextColor,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _buildAvatarImage(user) {

  if (_selectedAvatarBytes != null) {
    return MemoryImage(
      _selectedAvatarBytes!,
    );
  }

  if (user.avatar != null &&
      user.avatar!.isNotEmpty) {

    final avatarUrl =
        user.avatar!.startsWith('http')
            ? user.avatar!
            : '${AppUrls.baseUrl}/${user.avatar}';

    return NetworkImage(
      avatarUrl,
    );
  }

  return const NetworkImage(
    'https://miro.medium.com/v2/resize:fit:1079/1*G6bWZ2AzAAPVsl86NU-2bQ.png',
  );
}

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.actor(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.actor(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextColor,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.iconColor),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
              )
            : null,
        filled: true,
        fillColor: HexColor('FFFFFF').withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: HexColor('FFFFFF').withOpacity(0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.iconColor),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

// Add this extension to your User model if needed
// extension UserCopyWith on User {
//   User copyWith({
//     String? fullName,
//     String? phone,
//     String? avatar,
//   }) {
//     return User(
//       id: id,
//       fullName: fullName ?? this.fullName,
//       phone: phone ?? this.phone,
//       avatar: avatar ?? this.avatar,
//       token: token,
//       email: email,
//     );
//   }
// }