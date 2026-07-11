import 'dart:convert';
import 'dart:typed_data';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/pManagerPages/map_location_picker_page.dart';
import 'package:brickapp/pages/pManagerPages/pdf_pre_view.dart';
import 'package:brickapp/providers/settings_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:brickapp/utils/urls.dart';
import 'package:brickapp/providers/user_provider.dart';

class AddPost extends ConsumerStatefulWidget {
  final PropertyModel? editPostModel;
  const AddPost({super.key, this.editPostModel});

  @override
  ConsumerState<AddPost> createState() => _AddPostState();
}

class _AddPostState extends ConsumerState<AddPost> {
  final style = GoogleFonts.oxygen(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.darkTextColor,
  );

  final List<String> descriptions = [
    'House', 'Apartments', 'Business Shop', 'Venue',
    'Warehouse', 'Office Space', 'Land', 'Farm House',
  ];

  final List<String> packages = [
    '1 Month', '2 Months', '3 Months', '6 Months',
    '1 Year', '2 Years', 'Custom Months',
  ];

  final List<String> amenitiesList = [
    'Furnished', 'Air Conditioning', 'Parking', 'Security',
    'Internet', 'Pet Friendly', 'Compound', 'Swimming Pool',
    'Gym', 'Generator', 'CCTV', 'Borehole', 'Water Tank',
    'Solar Power', 'Balcony', 'Garden',
  ];

  String? selectedDescription;
  String? selectedPackage;
  String _location = 'Kampala, Uganda';
  double? _selectedLat;
  double? _selectedLng;
  bool _isLoadingLocation = false;
  bool _isRentSelected = true;
  bool _isSaleSelected = false;

  int? price;
  int? salePrice;
  String salesCondition = '';
  int? customMonths;

  int? dailyPrice;
  int? weeklyPrice;
  int? monthlyPrice;
  int? yearlyPrice;
  bool _isDailyEnabled = false;
  bool _isWeeklyEnabled = false;
  bool _isMonthlyEnabled = false;
  bool _isYearlyEnabled = false;

  bool _isPending = false;
  List<String> selectedAmenities = [];

  // ✅ All media stored as bytes immediately — fixes URL revoked error
  List<Uint8List> _selectedPhotoBytes = [];
  List<String> _selectedPhotoNames = [];
  Uint8List? _thumbnailBytes;
  String? _thumbnailName;
  Uint8List? _videoBytes;
  String? _videoName;
  XFile? _rulesDocument;
  String? _rulesDocumentName;

  final _descriptionController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _unitsController = TextEditingController();
  final _squareFeetController = TextEditingController();
  final _saleConditionController = TextEditingController();
  final _pendingReasonController = TextEditingController();
  final _customMonthsController = TextEditingController();

  bool _isLoading = false;

  bool get _isVenue =>
      selectedDescription == 'Venue' ||
      selectedDescription == 'Ceremony Ground';

  bool get _isLand => selectedDescription == 'Land';

  int _getMonthCount(String pkg) {
    switch (pkg) {
      case '1 Month': return 1;
      case '2 Months': return 2;
      case '3 Months': return 3;
      case '6 Months': return 6;
      case '1 Year': return 12;
      case '2 Years': return 24;
      case 'Custom Months': return customMonths ?? 1;
      default: return 1;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.editPostModel != null) _loadEditData();
  }

  void _loadEditData() {
    final p = widget.editPostModel!;
    selectedDescription = p.propertyType;
    _location = p.address ?? 'Kampala, Uganda';
    _selectedLat = p.latitude;
    _selectedLng = p.longitude;
    price = p.rentPrice?.toInt();
    salePrice = p.salePrice?.toInt();
    final lt = p.listingType ?? 'rent';
    _isRentSelected = lt == 'rent' || lt == 'rent_and_sale';
    _isSaleSelected = lt == 'sale' || lt == 'rent_and_sale';
    _descriptionController.text = p.description ?? '';
    _bedroomsController.text = p.bedrooms > 0 ? p.bedrooms.toString() : '';
    _bathroomsController.text = p.bathrooms > 0 ? p.bathrooms.toString() : '';
    _unitsController.text = p.units > 0 ? p.units.toString() : '';
    selectedAmenities = List.from(p.amenities);
    _isPending = p.status == 'pending';
    _pendingReasonController.text = p.pendingReason ?? '';
    if (p.venuePricing != null) {
  final vp = Map<String, dynamic>.from(p.venuePricing as Map);
  dailyPrice = (vp['daily'] as num?)?.toInt();
  weeklyPrice = (vp['weekly'] as num?)?.toInt();
  monthlyPrice = (vp['monthly'] as num?)?.toInt();
  yearlyPrice = (vp['yearly'] as num?)?.toInt();}
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _unitsController.dispose();
    _squareFeetController.dispose();
    _saleConditionController.dispose();
    _pendingReasonController.dispose();
    _customMonthsController.dispose();
    super.dispose();
  }

  // ✅ Read bytes immediately to prevent URL revoked error on web
  Future<void> _pickPhotos() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage();
      if (picked == null || picked.isEmpty) return;
      final remaining = 10 - _selectedPhotoBytes.length;
      final toAdd = picked.take(remaining).toList();
      for (final file in toAdd) {
        final bytes = await file.readAsBytes();
        if (mounted) setState(() {
          _selectedPhotoBytes.add(bytes);
          _selectedPhotoNames.add(file.name);
        });
      }
    } catch (e) {
      _showSnack('Error picking photos: $e', Colors.red);
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (mounted) setState(() { _thumbnailBytes = bytes; _thumbnailName = picked.name; });
    } catch (e) {
      _showSnack('Error picking thumbnail: $e', Colors.red);
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 5));
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.length > 50 * 1024 * 1024) { _showSnack('Video must be less than 50MB', Colors.red); return; }
      if (mounted) setState(() { _videoBytes = bytes; _videoName = picked.name; });
    } catch (e) {
      _showSnack('Error picking video: $e', Colors.red);
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx'], withData: true,
      );
      if (result == null || result.files.single.bytes == null) return;
      setState(() {
        _rulesDocument = XFile.fromData(result.files.single.bytes!, name: result.files.single.name);
        _rulesDocumentName = result.files.single.name;
      });
    } catch (e) {
      _showSnack('Error picking document: $e', Colors.red);
    }
  }

  void _showLocationOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          ListTile(
            leading: const Icon(Icons.map, color: Colors.orange),
            title: const Text('Pick on Map'),
            subtitle: const Text('Search or drop a pin'),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => MapLocationPicker(
                  onLocationSelected: (lat, lng, address) => setState(() {
                    _location = address; _selectedLat = lat; _selectedLng = lng;
                  }),
                ),
              ));
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showPriceDialog(BuildContext context) {
   final settings = ref.read(publicSettingsProvider).value ?? PublicSettings();
final commissionPercent = settings.commissionPercent;
final discountPercent = settings.clientDiscountPercent;
final commissionMonths = settings.commissionMonths;
    final priceController = TextEditingController(text: price?.toString() ?? '');
    String? localPackage = selectedPackage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final enteredPrice = int.tryParse(priceController.text) ?? 0;
          final months = _getMonthCount(localPackage ?? '1 Month');
          final commMonths = months < commissionMonths ? months : commissionMonths;
          final discount = enteredPrice * commMonths * (discountPercent / 100);
          final clientPays = enteredPrice - discount;
          final commission = enteredPrice * commMonths * (commissionPercent / 100);
          final managerGets = enteredPrice * months - commission;
          final fmt = NumberFormat('#,###');

          return AlertDialog(
            title: Text('Set Rental Price', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: 'Monthly Price (UGX)', prefixText: 'UGX ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  onChanged: (_) => setS(() {}),
                ),
                const SizedBox(height: 16),
                const Text('Rental Package', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: packages.map((pkg) {
                    final selected = localPackage == pkg;
                    return GestureDetector(
                      onTap: () => setS(() => localPackage = pkg),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? Colors.orange : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? Colors.orange : Colors.grey[300]!),
                        ),
                        child: Text(pkg, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
                if (localPackage == 'Custom Months') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customMonthsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: 'Number of Months', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    onChanged: (v) { customMonths = int.tryParse(v); setS(() {}); },
                  ),
                ],
                if (enteredPrice > 0 && localPackage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange[200]!)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Pricing Breakdown', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])),
                      const SizedBox(height: 8),
                      _bRow('Monthly price', 'UGX ${fmt.format(enteredPrice)}'),
                      _bRow('Duration', '$months month${months > 1 ? "s" : ""}'),
                      _bRow('Client discount (${discountPercent.toInt()}% × $commMonths mo)', '- UGX ${fmt.format(discount)}', color: Colors.green),
                      const Divider(height: 12),
                      _bRow('Client pays (first month)', 'UGX ${fmt.format(clientPays)}', bold: true),
                      _bRow('Platform commission ($commissionPercent%)', '- UGX ${fmt.format(commission)}', color: Colors.red),
                      _bRow('You receive', 'UGX ${fmt.format(managerGets)}', bold: true, color: Colors.green),
                    ]),
                  ),
                ],
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final p = int.tryParse(priceController.text);
                  if (p == null || p <= 0) { _showSnack('Enter a valid price', Colors.red); return; }
                  if (localPackage == null) { _showSnack('Select a package', Colors.red); return; }
                  setState(() { price = p; selectedPackage = localPackage; customMonths = int.tryParse(_customMonthsController.text); });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700]))),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.black87)),
      ]),
    );
  }

  Future<void> _showVenuePriceDialog(String period, Function(int) onSave) async {
    final controller = TextEditingController();
    final fmt = NumberFormat('#,###');
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final val = int.tryParse(controller.text) ?? 0;
          return AlertDialog(
            title: Text('Set $period Price'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: '$period Price (UGX)', prefixText: 'UGX ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                autofocus: true,
                onChanged: (_) => setS(() {}),
              ),
              if (val > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange[200]!)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('$period rate:'),
                    Text('UGX ${fmt.format(val)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ]),
                ),
              ],
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () { final p = int.tryParse(controller.text); if (p != null && p > 0) { onSave(p); Navigator.pop(ctx); } },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVenuePriceToggle({required String label, required IconData icon, required bool enabled, required int? price, required Function(bool) onToggle, required VoidCallback onSetPrice}) {
    final fmt = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: enabled ? Colors.orange[50] : const Color.fromARGB(179, 235, 246, 250),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: enabled ? Colors.orange[300]! : Colors.transparent),
      ),
      child: Row(children: [
        Icon(icon, color: enabled ? Colors.orange : Colors.grey[400], size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: style.copyWith(fontWeight: FontWeight.w500, color: enabled ? AppColors.darkTextColor : Colors.grey[500], fontSize: 14)),
          if (enabled && price != null)
            Text('UGX ${fmt.format(price)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13))
          else if (enabled)
            Text('Tap Set Price', style: TextStyle(color: Colors.orange[300], fontSize: 11)),
        ])),
        if (enabled) TextButton(onPressed: onSetPrice, child: Text(price != null ? 'Edit' : 'Set Price', style: const TextStyle(color: Colors.orange))),
        Switch(value: enabled, onChanged: onToggle, activeColor: Colors.orange),
      ]),
    );
  }

  Future<void> _submitPost() async {
    if (selectedDescription == null) { _showSnack('Please select property type', Colors.red); return; }
    if (_location.isEmpty || _location == 'Kampala, Uganda') { _showSnack('Please set property location', Colors.red); return; }

    // ✅ Units validation for non-venue, non-land
    if (!_isVenue && !_isLand) {
      final units = int.tryParse(_unitsController.text) ?? 0;
      if (units <= 0) { _showSnack('Please enter available units (must be at least 1)', Colors.red); return; }
    }

    if (_isVenue) {
      final hasPrice = (_isDailyEnabled && dailyPrice != null) || (_isWeeklyEnabled && weeklyPrice != null) || (_isMonthlyEnabled && monthlyPrice != null) || (_isYearlyEnabled && yearlyPrice != null);
      if (!hasPrice) { _showSnack('Enable and set at least one venue pricing package', Colors.red); return; }
    } else {
      if (_isRentSelected && price == null) { _showSnack('Please set rental price', Colors.red); return; }
      if (_isSaleSelected && salePrice == null) { _showSnack('Please set sale price', Colors.red); return; }
    }

    if (_thumbnailBytes == null && widget.editPostModel?.thumbnail == null) { _showSnack('Please add a thumbnail image', Colors.red); return; }

    setState(() => _isLoading = true);
    try {
      final token = ref.read(userProvider).token ?? '';
      final uri = Uri.parse(widget.editPostModel != null ? '${AppUrls.properties}/${widget.editPostModel!.id}' : '${AppUrls.properties}/create');
      final request = http.MultipartRequest(widget.editPostModel != null ? 'PATCH' : 'POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['property_type'] = selectedDescription!;
      request.fields['address'] = _location;
      request.fields['description'] = _descriptionController.text;
      request.fields['status'] = _isPending ? 'pending' : 'active';
      if (_isPending && _pendingReasonController.text.isNotEmpty) request.fields['pending_reason'] = _pendingReasonController.text;
      if (_selectedLat != null) request.fields['latitude'] = _selectedLat.toString();
      if (_selectedLng != null) request.fields['longitude'] = _selectedLng.toString();
      if (_bedroomsController.text.isNotEmpty) request.fields['bedrooms'] = _bedroomsController.text;
      if (_bathroomsController.text.isNotEmpty) request.fields['bathrooms'] = _bathroomsController.text;
      if (_unitsController.text.isNotEmpty) request.fields['units'] = _unitsController.text;
      if (_squareFeetController.text.isNotEmpty) request.fields['square_feet'] = _squareFeetController.text;
      if (selectedAmenities.isNotEmpty) request.fields['amenities'] = selectedAmenities.join(',');

      if (_isVenue) {
        request.fields['listing_type'] = 'rent';
        final map = <String, int>{};
        if (_isDailyEnabled && dailyPrice != null) { request.fields['daily_price'] = dailyPrice.toString(); map['daily'] = dailyPrice!; }
        if (_isWeeklyEnabled && weeklyPrice != null) { request.fields['weekly_price'] = weeklyPrice.toString(); map['weekly'] = weeklyPrice!; }
        if (_isMonthlyEnabled && monthlyPrice != null) { request.fields['monthly_price'] = monthlyPrice.toString(); request.fields['rent_price'] = monthlyPrice.toString(); map['monthly'] = monthlyPrice!; }
        if (_isYearlyEnabled && yearlyPrice != null) { request.fields['yearly_price'] = yearlyPrice.toString(); map['yearly'] = yearlyPrice!; }
        request.fields['venue_pricing'] = jsonEncode(map);
      } else {
        if (_isRentSelected && _isSaleSelected) request.fields['listing_type'] = 'rent_and_sale';
        else if (_isSaleSelected) request.fields['listing_type'] = 'sale';
        else request.fields['listing_type'] = 'rent';
        if (price != null && _isRentSelected) { request.fields['rent_price'] = price.toString(); request.fields['rent_duration_months'] = _getMonthCount(selectedPackage ?? '1 Month').toString(); }
        if (salePrice != null && _isSaleSelected) { request.fields['sale_price'] = salePrice.toString(); if (_saleConditionController.text.isNotEmpty) request.fields['sale_condition'] = _saleConditionController.text; }
      }

      for (int i = 0; i < _selectedPhotoBytes.length; i++) {
        request.files.add(http.MultipartFile.fromBytes('images', _selectedPhotoBytes[i], filename: _selectedPhotoNames[i]));
      }
      if (_thumbnailBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('thumbnail', _thumbnailBytes!, filename: _thumbnailName ?? 'thumbnail.jpg'));
      }
      if (_videoBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('video', _videoBytes!, filename: _videoName ?? 'video.mp4'));
      }
      if (_rulesDocument != null) {
        final docBytes = await _rulesDocument!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('document', docBytes, filename: _rulesDocumentName ?? 'document.pdf'));
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack(widget.editPostModel != null ? 'Property updated!' : 'Property posted!', Colors.green);
        Navigator.pop(context, true);
      } else {
        _showSnack('Error: ${data['message'] ?? 'Server error'}', Colors.red);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', Colors.red);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(widget.editPostModel != null ? 'Edit Property' : 'Add Property',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ─── Property Type ──────────────────────────
          _label('Property Type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: descriptions.map((d) {
              final sel = selectedDescription == d;
              return GestureDetector(
                onTap: () => setState(() {
                  selectedDescription = d; price = null; selectedPackage = null;
                  dailyPrice = null; weeklyPrice = null; monthlyPrice = null; yearlyPrice = null;
                  _isDailyEnabled = false; _isWeeklyEnabled = false; _isMonthlyEnabled = false; _isYearlyEnabled = false;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? Colors.orange : const Color.fromARGB(179, 235, 246, 250),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? Colors.orange : Colors.transparent),
                  ),
                  child: Text(d, style: style.copyWith(color: sel ? Colors.white : AppColors.darkTextColor, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ─── Listing Type ───────────────────────────
          if (!_isVenue) ...[
            _label('Listing Type'),
            const SizedBox(height: 8),
            Row(children: [
              _chip('For Rent', _isRentSelected, () => setState(() => _isRentSelected = !_isRentSelected)),
              const SizedBox(width: 8),
              _chip('For Sale', _isSaleSelected, () => setState(() => _isSaleSelected = !_isSaleSelected)),
            ]),
            const SizedBox(height: 24),
          ],

          // ─── Pricing ────────────────────────────────
          _label('Pricing'),
          const SizedBox(height: 8),
          if (_isVenue) ...[
            Text('Enable the packages you want to offer', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 10),
            _buildVenuePriceToggle(label: 'Daily Rate', icon: Icons.today, enabled: _isDailyEnabled, price: dailyPrice, onToggle: (v) => setState(() => _isDailyEnabled = v), onSetPrice: () => _showVenuePriceDialog('Daily', (p) => setState(() => dailyPrice = p))),
            const SizedBox(height: 8),
            _buildVenuePriceToggle(label: 'Weekly Rate', icon: Icons.view_week, enabled: _isWeeklyEnabled, price: weeklyPrice, onToggle: (v) => setState(() => _isWeeklyEnabled = v), onSetPrice: () => _showVenuePriceDialog('Weekly', (p) => setState(() => weeklyPrice = p))),
            const SizedBox(height: 8),
            _buildVenuePriceToggle(label: 'Monthly Rate', icon: Icons.calendar_month, enabled: _isMonthlyEnabled, price: monthlyPrice, onToggle: (v) => setState(() => _isMonthlyEnabled = v), onSetPrice: () => _showVenuePriceDialog('Monthly', (p) => setState(() => monthlyPrice = p))),
            const SizedBox(height: 8),
            _buildVenuePriceToggle(label: 'Yearly Rate', icon: Icons.calendar_today, enabled: _isYearlyEnabled, price: yearlyPrice, onToggle: (v) => setState(() => _isYearlyEnabled = v), onSetPrice: () => _showVenuePriceDialog('Yearly', (p) => setState(() => yearlyPrice = p))),
          ] else ...[
            if (_isRentSelected) ...[
              GestureDetector(
                onTap: () => _showPriceDialog(context),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: price != null ? Colors.orange[50] : const Color.fromARGB(179, 235, 246, 250),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: price != null ? Colors.orange : Colors.transparent),
                  ),
                  child: Row(children: [
                    Icon(Icons.home_work, color: price != null ? Colors.orange : Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(price != null ? 'UGX ${fmt.format(price!)}/month' : 'Set Rental Price Package',
                          style: style.copyWith(fontWeight: price != null ? FontWeight.w600 : FontWeight.normal, color: price != null ? AppColors.darkTextColor : Colors.grey, fontSize: 14)),
                      if (selectedPackage != null) Text(selectedPackage!, style: TextStyle(color: Colors.orange[700], fontSize: 12)),
                    ])),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (_isSaleSelected) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color.fromARGB(179, 235, 246, 250), borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: 'Sale Price (UGX)', prefixText: 'UGX ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.white),
                    onChanged: (v) => salePrice = int.tryParse(v),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _saleConditionController,
                    decoration: InputDecoration(labelText: 'Sale Conditions (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.white),
                  ),
                ]),
              ),
            ],
          ],
          const SizedBox(height: 24),

          // ─── Location ────────────────────────────────
        // ─── Location ────────────────────────────────
_label('Location'),
const SizedBox(height: 8),
GestureDetector(
  onTap: _showLocationOptions,
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _selectedLat != null ? Colors.orange[50] : const Color.fromARGB(179, 235, 246, 250),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _selectedLat != null ? Colors.orange : Colors.transparent),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _selectedLat != null ? Icons.location_on : Icons.location_on_outlined,
              color: _selectedLat != null ? Colors.orange : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _isLoadingLocation
                  ? const Row(
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('Getting location...', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full address
                        Text(
                          _location,
                          style: style.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedLat != null ? AppColors.darkTextColor : Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Latitude and Longitude
                        if (_selectedLat != null && _selectedLng != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${_selectedLat!.toStringAsFixed(6)}, ${_selectedLng!.toStringAsFixed(6)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[700],
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
        // Tap to change hint
        if (_selectedLat != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 12,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap to change location',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  ),
),
const SizedBox(height: 24),

          // ─── Property Details ─────────────────────────
          _label('Property Details'),
          const SizedBox(height: 8),
          if (!_isLand) ...[
            Row(children: [
              if (!_isVenue) ...[Expanded(child: _field(_bedroomsController, 'Bedrooms', Icons.bed)), const SizedBox(width: 12)],
              Expanded(child: _field(_bathroomsController, 'Bathrooms', Icons.bathroom)),
            ]),
            const SizedBox(height: 12),
          ],
          Row(children: [
            Expanded(child: _field(_unitsController, _isVenue ? 'Capacity' : 'Available Units', Icons.apartment, hint: _isVenue ? 'Max people' : 'e.g. 4')),
            const SizedBox(width: 12),
            Expanded(child: _field(_squareFeetController, 'Square Feet', Icons.square_foot, isDecimal: true)),
          ]),

          // ✅ Units warning
          if (!_isVenue && !_isLand) Builder(builder: (ctx) {
            final units = int.tryParse(_unitsController.text) ?? -1;
            if (units == 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orange[200]!)),
                  child: const Row(children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 14),
                    SizedBox(width: 6),
                    Expanded(child: Text('Property will not show to clients until units are available. Units restore when clients cancel or refund.', style: TextStyle(color: Colors.orange, fontSize: 11))),
                  ]),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description', hintText: 'Describe the property...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true, fillColor: const Color.fromARGB(179, 235, 246, 250),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Coming Soon ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isPending ? Colors.orange[50] : const Color.fromARGB(179, 235, 246, 250),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _isPending ? Colors.orange[200]! : Colors.transparent),
            ),
            child: Column(children: [
              SwitchListTile(
                value: _isPending, onChanged: (v) => setState(() => _isPending = v),
                title: Text('Mark as Coming Soon', style: style.copyWith(fontWeight: FontWeight.w600)),
                subtitle: const Text('Clients can book to reserve their spot', style: TextStyle(fontSize: 12)),
                activeColor: Colors.orange, contentPadding: EdgeInsets.zero,
              ),
              if (_isPending) ...[
                const SizedBox(height: 8),
                TextField(controller: _pendingReasonController, decoration: InputDecoration(labelText: 'Reason / Expected ready date', hintText: 'e.g. Ready by March 2025', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              ],
            ]),
          ),
          const SizedBox(height: 24),

          // ─── Amenities ────────────────────────────────
          _label('Amenities'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: amenitiesList.map((a) {
              final sel = selectedAmenities.contains(a);
              return GestureDetector(
                onTap: () => setState(() { if (sel) selectedAmenities.remove(a); else selectedAmenities.add(a); }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? Colors.orange : const Color.fromARGB(179, 235, 246, 250),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? Colors.orange : Colors.transparent),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (sel) ...[const Icon(Icons.check, color: Colors.white, size: 12), const SizedBox(width: 4)],
                    Text(a, style: style.copyWith(color: sel ? Colors.white : AppColors.darkTextColor, fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ─── Thumbnail ────────────────────────────────
          _label('Thumbnail Image *'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickThumbnail,
            child: Container(
              width: double.infinity, height: 160,
              decoration: BoxDecoration(
                color: const Color.fromARGB(179, 235, 246, 250),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _thumbnailBytes != null ? Colors.orange : Colors.transparent),
              ),
              child: _thumbnailBytes != null
                  ? Stack(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_thumbnailBytes!, width: double.infinity, height: 160, fit: BoxFit.cover)),
                      Positioned(top: 8, right: 8, child: GestureDetector(
                        onTap: () => setState(() { _thumbnailBytes = null; _thumbnailName = null; }),
                        child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 20)),
                      )),
                    ])
                  : widget.editPostModel?.thumbnail != null
                      ? Stack(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network('${AppUrls.baseUrl}/${widget.editPostModel!.thumbnail}', width: double.infinity, height: 160, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _thumbEmpty())),
                          Positioned(bottom: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)), child: const Text('Tap to change', style: TextStyle(color: Colors.white, fontSize: 10)))),
                        ])
                      : _thumbEmpty(),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Gallery ──────────────────────────────────
          _label('Gallery Photos (${_selectedPhotoBytes.length}/10)'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectedPhotoBytes.length < 10 ? _pickPhotos : null,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color.fromARGB(179, 235, 246, 250), borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_photo_alternate, color: _selectedPhotoBytes.length < 10 ? Colors.grey : Colors.grey[300]),
                const SizedBox(width: 8),
                Text(_selectedPhotoBytes.length < 10 ? 'Add Photos (${10 - _selectedPhotoBytes.length} remaining)' : 'Maximum 10 photos', style: TextStyle(color: Colors.grey[600])),
              ]),
            ),
          ),
          if (_selectedPhotoBytes.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedPhotoBytes.length,
                itemBuilder: (_, i) => Stack(children: [
                  Container(margin: const EdgeInsets.only(right: 8), width: 90, height: 90,
                      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(_selectedPhotoBytes[i], fit: BoxFit.cover))),
                  Positioned(top: 4, right: 4, child: GestureDetector(
                    onTap: () => setState(() { _selectedPhotoBytes.removeAt(i); _selectedPhotoNames.removeAt(i); }),
                    child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 16)),
                  )),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // ─── Video ────────────────────────────────────
          _label('Property Video (optional)'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickVideo,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _videoBytes != null ? Colors.orange[50] : const Color.fromARGB(179, 235, 246, 250),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _videoBytes != null ? Colors.orange : Colors.transparent),
              ),
              child: Row(children: [
                Icon(_videoBytes != null ? Icons.videocam : Icons.videocam_outlined, color: _videoBytes != null ? Colors.orange : Colors.grey),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_videoBytes != null ? (_videoName ?? 'Video selected') : 'Add a property walkthrough video',
                      style: style.copyWith(color: _videoBytes != null ? AppColors.darkTextColor : Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (_videoBytes != null) Text('${(_videoBytes!.length / (1024 * 1024)).toStringAsFixed(1)} MB', style: TextStyle(fontSize: 11, color: Colors.orange[600])),
                ])),
                if (_videoBytes != null) GestureDetector(onTap: () => setState(() { _videoBytes = null; _videoName = null; }), child: const Icon(Icons.close, color: Colors.grey, size: 18)),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Document ─────────────────────────────────
          _label('Rules / Agreement Document (optional)'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDocument,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _rulesDocument != null ? Colors.green[50] : const Color.fromARGB(179, 235, 246, 250),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _rulesDocument != null ? Colors.green : Colors.transparent),
              ),
              child: Row(children: [
                Icon(_rulesDocument != null ? Icons.description : Icons.upload_file, color: _rulesDocument != null ? Colors.green : Colors.grey),
                const SizedBox(width: 12),
                Expanded(child: Text(_rulesDocumentName ?? 'Upload PDF/DOC rules document',
                    style: style.copyWith(color: _rulesDocument != null ? AppColors.darkTextColor : Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (_rulesDocument != null) ...[
                  TextButton(
                    onPressed: () async {
                      final bytes = await _rulesDocument!.readAsBytes();
                      if (!mounted) return;
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentPreviewScreen(fileBytes: bytes, fileName: _rulesDocumentName ?? 'document.pdf', title: 'Document Preview')));
                    },
                    child: const Text('Preview', style: TextStyle(color: Colors.green)),
                  ),
                  GestureDetector(onTap: () => setState(() { _rulesDocument = null; _rulesDocumentName = null; }), child: const Icon(Icons.close, color: Colors.grey, size: 18)),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 32),

          // ─── Submit ───────────────────────────────────
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, disabledBackgroundColor: Colors.orange[200], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isLoading
                  ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), SizedBox(width: 12), Text('Posting...', style: TextStyle(color: Colors.white, fontSize: 16))])
                  : Text(widget.editPostModel != null ? 'Update Property' : 'Post Property', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text(t, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkTextColor)));

  Widget _chip(String label, bool sel, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: sel ? Colors.orange : const Color.fromARGB(179, 235, 246, 250), borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? Colors.orange : Colors.transparent)),
      child: Text(label, style: style.copyWith(color: sel ? Colors.white : AppColors.darkTextColor, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
    ),
  );

  Widget _field(TextEditingController c, String label, IconData icon, {bool isDecimal = false, String? hint}) => TextField(
    controller: c,
    keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
    inputFormatters: [isDecimal ? FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')) : FilteringTextInputFormatter.digitsOnly],
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: const Color.fromARGB(179, 235, 246, 250), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
  );

  Widget _thumbEmpty() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
    const SizedBox(height: 8),
    Text('Tap to add thumbnail', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
    Text('Main image shown in listings', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
  ]);
}
