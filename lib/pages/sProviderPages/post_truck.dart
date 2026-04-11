import 'dart:io';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class PostTruckPage extends ConsumerStatefulWidget {
  const PostTruckPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PostTruckPage> createState() => _PostTruckPageState();
}

class _PostTruckPageState extends ConsumerState<PostTruckPage> {
  final _formKey = GlobalKey<FormState>();

  // ─── Dynamic vehicle types from backend ─────────────
  List<Map<String, dynamic>> _vehicleTypes = [];
  bool _loadingTypes = true;
  Map<String, dynamic>? _selectedVehicleType;

  File? _vehiclePhoto;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedCountryCode = '+256';

  @override
  void initState() {
    super.initState();
    _loadVehicleTypes();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ─── Fetch vehicle types + prices from backend ───────
  Future<void> _loadVehicleTypes() async {
    setState(() => _loadingTypes = true);
    try {
      final res = await http.get(
        Uri.parse('${AppUrls.baseUrl}/transport/truck-types-all'),
      );

      print('📡 Vehicle types response: ${res.statusCode}');
      print('📡 Response body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print('📡 Decoded data structure: ${data.keys}');

        final types = List<Map<String, dynamic>>.from(data['types']);

        // ✅ Verify each type has price_per_km
        for (var type in types) {
          print(
            '✅ Type: ${type['name']} - ID: ${type['id']} - Price/km: ${type['price_per_km']}',
          );
          if (type['price_per_km'] == null) {
            print('⚠️ WARNING: ${type['name']} has no price_per_km!');
          }
        }

        setState(() {
          _vehicleTypes = types;
        });
      } else {
        print('❌ Failed to load vehicle types');
        _useFallbackTypes();
      }
    } catch (e) {
      print('❌ Failed to load vehicle types: $e');
      _useFallbackTypes();
    }
    setState(() => _loadingTypes = false);
  }

  void _useFallbackTypes() {
    _vehicleTypes = [
      {'id': 1, 'name': 'Small Truck', 'price_per_km': 50000},
      {'id': 2, 'name': 'Medium Truck', 'price_per_km': 80000},
      {'id': 3, 'name': 'Large Truck', 'price_per_km': 120000},
      {'id': 4, 'name': 'Trailer', 'price_per_km': 200000},
      {'id': 5, 'name': 'Bus', 'price_per_km': 45000},
      {'id': 6, 'name': 'Costa', 'price_per_km': 30000},
    ];
  }

  IconData _getVehicleIcon(String name) {
    switch (name) {
      case 'Small Truck':
        return Icons.local_shipping;
      case 'Medium Truck':
        return Icons.fire_truck;
      case 'Large Truck':
        return Icons.airport_shuttle;
      case 'Trailer':
        return Icons.rv_hookup;
      case 'Bus':
        return Icons.directions_bus;
      case 'Costa':
        return Icons.directions_bus_filled;
      default:
        return Icons.local_shipping;
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final num p = price is num ? price : num.tryParse(price.toString()) ?? 0;
    return p.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 75,
    );
    if (picked != null) setState(() => _vehiclePhoto = File(picked.path));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleType == null) {
      _showSnack('Please select a vehicle type', Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = ref.read(userProvider).token;
      if (token == null) {
        _showErrorDialog('You must be logged in');
        setState(() => _isSubmitting = false);
        return;
      }

      final fullPhone = '$_selectedCountryCode${_phoneController.text}';

      // ✅ Debug: Check if price_per_km exists
      print('🔍 Selected vehicle type details:');
      print('  ID: ${_selectedVehicleType!['id']}');
      print('  Name: ${_selectedVehicleType!['name']}');
      print('  Price per km: ${_selectedVehicleType!['price_per_km']}');

      if (_selectedVehicleType!['price_per_km'] == null) {
        _showErrorDialog(
          'Vehicle type has no price set. Please contact admin.',
        );
        setState(() => _isSubmitting = false);
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppUrls.baseUrl}/vehicles'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // ✅ Send all required fields
      request.fields['brand'] = _modelController.text;
      request.fields['plate_number'] = _plateController.text;
      request.fields['vehicle_type_id'] =
          _selectedVehicleType!['id'].toString();
      request.fields['capacity'] = _capacityController.text;
      request.fields['phone'] = fullPhone;
      request.fields['email'] = _emailController.text;

      // ✅ Optional: Send price_per_km explicitly if backend needs it
      // request.fields['price_per_km'] = _selectedVehicleType!['price_per_km'].toString();
      request.fields['price_per_km'] =
          _selectedVehicleType!['price_per_km'].toString();
      // ✅ Log the request fields for debugging
      print('📤 Request fields:');
      request.fields.forEach((key, value) {
        print('  $key: $value');
      });

      if (_vehiclePhoto != null) {
        final ext = _vehiclePhoto!.path.split('.').last.toLowerCase();
        final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            _vehiclePhoto!.path,
            contentType: MediaType.parse(mime),
          ),
        );
        print('📷 Photo attached: ${_vehiclePhoto!.path}');
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: $body');

      setState(() => _isSubmitting = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        final data = jsonDecode(body);
        _showErrorDialog(data['message'] ?? 'Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isSubmitting = false);
      _showErrorDialog('Error: $e');
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text('Posted!', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              '${_selectedVehicleType!['name']} posted successfully!\nYou\'ll start receiving bookings soon.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _clearForm();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _clearForm() {
    _modelController.clear();
    _plateController.clear();
    _capacityController.clear();
    _phoneController.clear();
    _emailController.clear();
    setState(() {
      _selectedVehicleType = null;
      _vehiclePhoto = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Your Vehicle',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: AppColors.iconColor,
        elevation: 0,
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
                _buildHeader(),
                const SizedBox(height: 24),
                _buildVehicleTypeSection(),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Vehicle Details',
                  icon: Icons.local_shipping,
                  children: [
                    _buildTextField(
                      controller: _modelController,
                      label: 'Vehicle Model / Brand',
                      hint: 'e.g. ISUZU NPR, Toyota Coaster',
                      icon: Icons.directions_car,
                    ),
                    _buildTextField(
                      controller: _plateController,
                      label: 'License Plate',
                      hint: 'e.g. UBG 256Y',
                      icon: Icons.confirmation_number,
                    ),
                    _buildTextField(
                      controller: _capacityController,
                      label: 'Capacity',
                      hint: 'e.g. 5 tons / 30 passengers',
                      icon: Icons.inventory,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Vehicle Photo',
                  icon: Icons.photo_library,
                  children: [_buildPhotoPicker()],
                ),
                const SizedBox(height: 20),

                _buildSection(
                  title: 'Contact Information',
                  icon: Icons.contact_phone,
                  children: [
                    _buildPhoneField(),
                    const SizedBox(height: 16), // ✅ Add this
                    _buildTextField(
                      // ✅ Add email field back
                      controller: _emailController,
                      label: 'Email Address (optional)',
                      hint: 'e.g. driver@gmail.com',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      required: false,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Post Your Vehicle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'List your truck, bus or costa and start receiving bookings.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Vehicle Type Selector ────────────────────────────
  Widget _buildVehicleTypeSection() {
    return _buildSection(
      title: 'Vehicle Type',
      icon: Icons.category,
      children: [
        if (_loadingTypes)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Column(
            children: [
              // ✅ Prices note
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Prices per km are set by the platform admin and may change.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Vehicle type cards
              ..._vehicleTypes.map((type) {
                final isSelected = _selectedVehicleType?['id'] == type['id'];
                final pricePerKm = type['price_per_km'];

                return GestureDetector(
                  onTap: () => setState(() => _selectedVehicleType = type),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.iconColor.withOpacity(0.08)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.iconColor
                                : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.iconColor.withOpacity(0.15)
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getVehicleIcon(type['name']),
                            color:
                                isSelected
                                    ? AppColors.iconColor
                                    : Colors.grey[600],
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Name + price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color:
                                      isSelected
                                          ? AppColors.iconColor
                                          : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'UGX ${_formatPrice(pricePerKm)} / km',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      isSelected
                                          ? AppColors.iconColor.withOpacity(0.8)
                                          : Colors.grey[600],
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Checkmark
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.iconColor,
                            size: 22,
                          )
                        else
                          Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey[400],
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: AppColors.iconColor),
                ),
                const SizedBox(width: 8),
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
            const SizedBox(height: 12),
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
    bool required = true, // ✅ Add this
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.iconColor, width: 2),
          ),
        ),
        validator:
            required
                ? (v) => v == null || v.isEmpty ? 'Required' : null
                : null, // ✅ Optional fields skip validation
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Column(
      children: [
        _vehiclePhoto != null
            ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _vehiclePhoto!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _vehiclePhoto = null),
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
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
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
                    'Upload Vehicle Photo\nPNG, JPG up to 10MB',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Camera'),
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
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Gallery'),
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

  Widget _buildPhoneField() {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: DropdownButtonFormField<String>(
            value: _selectedCountryCode,
            items:
                ['+256', '+255', '+254', '+250']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
            onChanged: (v) => setState(() => _selectedCountryCode = v!),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.flag),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '7XX XXX XXX',
              prefixIcon: Icon(Icons.phone, color: AppColors.iconColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.iconColor, width: 2),
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.iconColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            _isSubmitting
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
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedVehicleType != null
                          ? 'Post ${_selectedVehicleType!['name']}'
                          : 'Post Vehicle',
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
