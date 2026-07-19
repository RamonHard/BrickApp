import 'dart:convert';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PropertyBookingPage extends ConsumerStatefulWidget {
  const PropertyBookingPage({super.key, required this.productModel});
  final PropertyModel productModel;

  @override
  ConsumerState<PropertyBookingPage> createState() =>
      _PropertyBookingPageState();
}

class _PropertyBookingPageState extends ConsumerState<PropertyBookingPage> {
  final formatter = NumberFormat('#,###');
// ✅ Add with other state variables
String? _selectedPaymentMethod;
  // Months state
  int _extraMonths = 0;
  bool _isSubmitting = false;

  // Commission settings — fetched from backend
  double _commissionPercent = 10.0;
  double _clientDiscountPercent = 8.0;
  bool _settingsLoaded = false;
  int _commissionableMonthsLimit = 3;

  // Add a flag to prevent multiple navigation attempts
  bool _isNavigating = false;

 
  @override
void initState() {
  super.initState();
_loadSettings();
  _loadPMPaymentMethods();
}

 Future<void> _loadSettings() async {
  try {
    print('════════════════════════════════════════');
    print('🌐 FETCHING PUBLIC PRICING SETTINGS');
    print('════════════════════════════════════════');

    final response = await http.get(
      Uri.parse('${AppUrls.baseUrl}/settings/public'),
    );

    print('📡 Settings status: ${response.statusCode}');
    print('📡 Settings response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch settings. Status: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    dynamic rawSettings = decoded['settings'];

    double? commission;
    double? discount;
    int? commissionMonths;

    /*
    CASE 1:
    [
      {"key": "...", "value": "..."}
    ]
    */
    if (rawSettings is List) {
      for (final setting in rawSettings) {
        if (setting is! Map) continue;

        final key = setting['key']?.toString();
        final value = setting['value']?.toString();

        print('⚙️ SETTING FROM API: $key = $value');

        if (key == 'property_commission_percent') {
          commission = double.tryParse(value ?? '');
        }

        if (key == 'client_discount_percent') {
          discount = double.tryParse(value ?? '');
        }

        if (key == 'commission_months') {
          commissionMonths = int.tryParse(value ?? '');
        }
      }
    }

    /*
    CASE 2:
    {
      "property_commission_percent": "6",
      "client_discount_percent": "4",
      "commission_months": "3"
    }
    */
    else if (rawSettings is Map) {
      print('⚙️ Settings returned as MAP');

      commission = double.tryParse(
        rawSettings['property_commission_percent']?.toString() ?? '',
      );

      discount = double.tryParse(
        rawSettings['client_discount_percent']?.toString() ?? '',
      );

      commissionMonths = int.tryParse(
        rawSettings['commission_months']?.toString() ?? '',
      );
    }

    if (!mounted) return;

    setState(() {
      if (commission != null) {
        _commissionPercent = commission!;
      }

      if (discount != null) {
        _clientDiscountPercent = discount!;
      }

      if (commissionMonths != null && commissionMonths! > 0) {
        _commissionableMonthsLimit = commissionMonths!;
      }

      _settingsLoaded = true;
    });

    print('════════════════════════════════════════');
    print('✅ FINAL PRICING VALUES USED BY APP');
    print('💰 Commission: $_commissionPercent%');
    print('🎉 Client Discount: $_clientDiscountPercent%');
    print('📅 Commission Months: $_commissionableMonthsLimit');
    print('════════════════════════════════════════');

    if (commission == null) {
      print(
        '⚠️ WARNING: property_commission_percent was not found or could not be parsed',
      );
    }

    if (discount == null) {
      print(
        '⚠️ WARNING: client_discount_percent was not found or could not be parsed',
      );
    }

    if (commissionMonths == null) {
      print(
        '⚠️ WARNING: commission_months was not found or could not be parsed',
      );
    }
  } catch (e, stackTrace) {
    print('❌ SETTINGS ERROR: $e');
    print(stackTrace);

    if (mounted) {
      setState(() {
        _settingsLoaded = true;
      });
    }
  }
}

  DateTime? _venueStartDate;
  DateTime? _venueEndDate;
  final TextEditingController _landValueController = TextEditingController();

  // ─── Calculations ───────────────────────────────────
  double get _pricePerMonth => (widget.productModel.rentPrice ?? 0).toDouble();

  int get _minimumMonths {
    if (widget.productModel.numberOfMonths.isNotEmpty &&
        widget.productModel.numberOfMonths != '0' &&
        widget.productModel.numberOfMonths != 'null') {
      return int.tryParse(widget.productModel.numberOfMonths) ?? 1;
    }
    return widget.productModel.minimumMonths ?? 1;
  }

  int get _totalMonths => _minimumMonths + _extraMonths;

  double get _baseTotal {
    if (_isVenue) return _dailyPrice * _venueDays;
    if (_isLand) {
  final landValue = double.tryParse(_landValueController.text) ?? 0;
  final percentage = widget.productModel.landPercentage ?? _commissionPercent; // Use state variable here
  return landValue * (percentage / 100);
}
    return _pricePerMonth * _totalMonths;
  }

  // ✅ NEW: Commissionable months (first N months only)
  int get _commissionableMonths =>
      _totalMonths < _commissionableMonthsLimit
          ? _totalMonths
          : _commissionableMonthsLimit;

  // ✅ NEW: Commissionable amount (only the months that earn commission)
  double get _commissionableAmount {
    if (_isVenue || _isLand) return _baseTotal; // all for venue/land
    return _pricePerMonth * _commissionableMonths; // only commission months
  }

  // ✅ NEW: Company's agreed commission from manager (e.g., 8% of commissionable amount)
  double get _agreedManagerCommission =>
      _commissionableAmount * (_commissionPercent / 100);

  // ✅ NEW: Client discount is % of commissionable amount (given from our commission)
  double get _clientDiscount =>
      _commissionableAmount * (_clientDiscountPercent / 100);

  // ✅ NEW: Client pays: (commissionableAmount - discount) + remainingAmount
  double get _finalTotal {
    if (_isVenue || _isLand) {
      return _baseTotal - _clientDiscount;
    }
    final remainingAmount = _baseTotal - _commissionableAmount;
    return (_commissionableAmount - _clientDiscount) + remainingAmount;
  }

  // ✅ NEW: Company keeps: agreed commission minus discount given
  double get _companyKeeps => _agreedManagerCommission - _clientDiscount;

  // ✅ NEW: Manager gets: commissionableAmount - agreedCommission + remainingAmount
  double get _managerGets {
    if (_isVenue || _isLand) {
      return _baseTotal - _agreedManagerCommission;
    }
    final remainingAmount = _baseTotal - _commissionableAmount;
    return (_commissionableAmount - _agreedManagerCommission) + remainingAmount;
  }
  // Add these with other state variables
Map<String, dynamic>? _pmPaymentMethods;
bool _isLoadingPaymentMethods = false;

  // ✅ NEW: You save (discount amount)
  double get _youSave => _clientDiscount;
  int get _venueDays {
    if (_venueStartDate == null || _venueEndDate == null) return 0;
    return _venueEndDate!.difference(_venueStartDate!).inDays;
  }

  // ✅ Property type checkers
  bool get _isLand => widget.productModel.propertyType == 'Land';
  bool get _isVenue => widget.productModel.propertyType == 'Venue';
  bool get _isRegular => !_isLand && !_isVenue;
  double get _dailyPrice => (widget.productModel.rentPrice ?? 0).toDouble();
  @override
  void dispose() {
    _landValueController.dispose();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (!_settingsLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Booking Details',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 16),
              Text('Loading pricing...'),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booking Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPropertyImage(width),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productModel.propertyType,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.productModel.location,
                          style: TextStyle(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildDurationSelector(),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildPriceBreakdown(),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                 // ─── Payment Methods Section ───────────────────
// ─── Payment Methods Section ───────────────────
// ✅ Replace the hardcoded payment options section
const Text('Select Payment Method',
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 12),

// ✅ Replace the payment options section
if (_isLoadingPaymentMethods)
  const Center(child: CircularProgressIndicator())
else if (_pmPaymentMethods == null)
  _buildNoPaymentMethods()
else ...[
  // MTN Mobile Money
  if (_pmPaymentMethods!['payment_mobile_money_enabled'] == 'true')
    _PaymentOption(
      title: '${_pmPaymentMethods!['payment_mobile_money_provider'] ?? 'MTN'} Mobile Money',
      subtitle: _pmPaymentMethods!['payment_mobile_money_number'] ?? '',
      icon: Icons.phone_android,
      color: Colors.yellow[700]!,
      isSelected: _selectedPaymentMethod == 'mobile_money',
      onSelected: () {
        setState(() => _selectedPaymentMethod = 'mobile_money');
        _showMobileMoneyFlow();
      },
    ),
  if (_pmPaymentMethods!['payment_mobile_money_enabled'] == 'true')
    const SizedBox(height: 8),

  // Airtel Money
  if (_pmPaymentMethods!['payment_airtel_enabled'] == 'true')
    _PaymentOption(
      title: 'Airtel Money',
      subtitle: _pmPaymentMethods!['payment_airtel_number'] ?? '',
      icon: Icons.phone_android,
      color: Colors.red,
      isSelected: _selectedPaymentMethod == 'airtel',
      onSelected: () {
        setState(() => _selectedPaymentMethod = 'airtel');
        _showMobileMoneyFlow();
      },
    ),
  if (_pmPaymentMethods!['payment_airtel_enabled'] == 'true')
    const SizedBox(height: 8),

  // Bank Transfer
  if (_pmPaymentMethods!['payment_bank_enabled'] == 'true')
    _PaymentOption(
      title: _pmPaymentMethods!['payment_bank_name'] ?? 'Bank Transfer',
      subtitle: 'Acc: ${_pmPaymentMethods!['payment_bank_account_number'] ?? ''}',
      icon: Icons.account_balance,
      color: Colors.brown,
      isSelected: _selectedPaymentMethod == 'bank',
      onSelected: () => setState(() => _selectedPaymentMethod = 'bank'),
    ),
],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
Future<void> _loadPMPaymentMethods() async {
  try {
    // ✅ Load platform payment methods set by admin
    final res = await http.get(
      Uri.parse(AppUrls.platformPaymentMethods),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() => _pmPaymentMethods = data['methods']);
    }
  } catch (e) {
    print('❌ Load payment methods: $e');
  }
  setState(() => _isLoadingPaymentMethods = false);
}
  Widget _buildDurationSelector() {
    if (_isLand) return _buildLandSelector();
    if (_isVenue) return _buildVenueDateSelector();
    return _buildMonthsSelector(); // ✅ calls the months selector
  }

  Widget _buildLandSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Land Purchase',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Commission: ${widget.productModel.landPercentage ?? 10}% of total land value',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter total land value (UGX):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _landValueController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'e.g. 50,000,000',
                  prefixText: 'UGX ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              if (_landValueController.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Our fee (${widget.productModel.landPercentage ?? 10}%): '
                  'UGX ${formatter.format(_baseTotal)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVenueDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Venue Booking',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'UGX ${formatter.format(_dailyPrice)} per day',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Start date
        GestureDetector(
          onTap: () => _pickDate(isStart: true),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  _venueStartDate == null
                      ? 'Select start date'
                      : 'From: ${_venueStartDate!.toString().substring(0, 10)}',
                  style: TextStyle(
                    color: _venueStartDate == null ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // End date
        GestureDetector(
          onTap:
              _venueStartDate == null ? null : () => _pickDate(isStart: false),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  _venueStartDate == null
                      ? Colors.grey[100]
                      : Colors.orange[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    _venueStartDate == null
                        ? Colors.grey[300]!
                        : Colors.orange[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _venueStartDate == null ? Colors.grey : Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  _venueEndDate == null
                      ? 'Select end date'
                      : 'To: ${_venueEndDate!.toString().substring(0, 10)}',
                  style: TextStyle(
                    color: _venueEndDate == null ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Days summary
        if (_venueStartDate != null && _venueEndDate != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total days:', style: TextStyle(color: Colors.green[800])),
                Text(
                  '$_venueDays day${_venueDays > 1 ? "s" : ""}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStart
              ? now
              : (_venueStartDate?.add(const Duration(days: 1)) ?? now),
      firstDate: isStart ? now : (_venueStartDate ?? now),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _venueStartDate = picked;
          // Reset end date if it's before new start date
          if (_venueEndDate != null && _venueEndDate!.isBefore(picked)) {
            _venueEndDate = null;
          }
        } else {
          _venueEndDate = picked;
        }
      });
    }
  }

  Widget _buildPriceBreakdown() {
  if (_isLand && _landValueController.text.isEmpty) {
    return const Center(
      child: Text(
        'Enter land value above to see price breakdown',
        style: TextStyle(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  if (_isVenue && _venueDays == 0) {
    return const Center(
      child: Text(
        'Select dates above to see price breakdown',
        style: TextStyle(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Price Breakdown',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),

      // ─── Base calculation ─────────────────────────
      if (_isVenue) ...[
        _buildPriceRow('Price per day', 'UGX ${formatter.format(_dailyPrice)}'),
        _buildPriceRow('Number of days', '$_venueDays days'),
      ] else if (_isLand) ...[
        _buildPriceRow(
          'Land value',
          'UGX ${formatter.format(double.tryParse(_landValueController.text) ?? 0)}',
        ),
      ] else ...[
        _buildPriceRow('Price per month', 'UGX ${formatter.format(_pricePerMonth)}'),
        _buildPriceRow('Total months', '$_totalMonths months'),
      ],

      _buildPriceRow('Base total', 'UGX ${formatter.format(_baseTotal)}', isBold: true),

      // ─── Commissionable section ───────────────────
      if (_isRegular && _commissionableMonths < _totalMonths) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discount applies on first $_commissionableMonths of $_totalMonths months:',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
             
            ],
          ),
        ),
      ],

      const Divider(height: 20),

      // ✅ 1. Agreed Commission (e.g., 8%)
      

      // ─── Final total ──────────────────────────────
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'You Pay',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'UGX ${formatter.format(_finalTotal)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          '🎉 You save UGX ${formatter.format(_youSave)} by paying through Brick!',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyImage(double width) {
    final thumbnail = widget.productModel.thumbnailUrl ?? '';
    return thumbnail.isNotEmpty
        ? Image.network(
          thumbnail,
          width: width,
          height: 220,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Container(
                width: width,
                height: 220,
                color: Colors.grey[300],
                child: const Icon(Icons.home, size: 60, color: Colors.grey),
              ),
        )
        : Container(
          width: width,
          height: 220,
          color: Colors.grey[300],
          child: const Icon(Icons.home, size: 60, color: Colors.grey),
        );
  }

  // ─── Mobile Money Flow ───────────────────────────────
  void _showMobileMoneyFlow() {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.phone_android, color: Colors.orange),
                SizedBox(width: 8),
                Text('Mobile Money'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount: UGX ${formatter.format(_finalTotal)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Enter your Mobile Money number:'),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+256 7XX XXX XXX',
                    prefixIcon: const Icon(Icons.phone, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (phoneController.text.isEmpty) return;
                  Navigator.pop(ctx);
                  _showPinPrompt(phoneController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  void _showPinPrompt(String phone) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.lock, color: Colors.orange),
                SizedBox(width: 8),
                Text('Enter PIN'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Authorizing payment of\nUGX ${formatter.format(_finalTotal)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  'from $phone',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '••••',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use PIN: 1234 (test mode)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (pinController.text == '1234') {
                    // Close PIN dialog first
                    Navigator.pop(ctx);
                    // Small delay to ensure dialog is closed
                    await Future.delayed(const Duration(milliseconds: 100));
                    // Then process booking
                    _processBooking(phone);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Wrong PIN. Use 1234 for testing.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Pay Now'),
              ),
            ],
          ),
    );
  }

  // ─── Process Booking ─────────────────────────────────
  // ─── Process Booking ─────────────────────────────────
  // ─── Process Booking ─────────────────────────────────
  Future<void> _processBooking(String phone) async {
    // Validation
    if (_isVenue && (_venueStartDate == null || _venueEndDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select venue dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isLand && _landValueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the land value'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.orange),
                SizedBox(height: 16),
                Text('Processing payment...'),
                SizedBox(height: 4),
                Text(
                  'Please wait',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
    );

    await Future.delayed(const Duration(seconds: 2));

    try {
      final token = ref.read(userProvider).token;

      // ✅ Build request body based on property type
      Map<String, dynamic> body;

      if (_isVenue) {
        body = {
          'property_id': widget.productModel.id,
          'start_date': _venueStartDate!.toIso8601String(),
          'end_date': _venueEndDate!.toIso8601String(),
          'booking_days': _venueDays,
          'payment_method': 'mobile_money',
          'payment_phone': phone,
        };
      } else if (_isLand) {
        final landValue = double.tryParse(_landValueController.text) ?? 0;
        body = {
          'property_id': widget.productModel.id,
          'land_total_value': landValue,
          'payment_method': 'mobile_money',
          'payment_phone': phone,
        };
      } else {
        // Regular monthly - backend will calculate months from dates
        final startDate = DateTime.now();
        final endDate = DateTime(
          startDate.year,
          startDate.month + _totalMonths,
          startDate.day,
        );
        body = {
          'property_id': widget.productModel.id,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'payment_method': 'mobile_money',
          'payment_phone': phone,
          // ❌ REMOVED: total_months (backend calculates from dates)
        };
      }

      print('📤 Sending booking request (backend will calculate pricing)');
      print('📤 Body: $body');

      final res = await http.post(
        Uri.parse(AppUrls.bookProperty),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);
      Navigator.pop(context); // close processing dialog

      if (res.statusCode == 200 && data['status'] == true) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'Booking failed: ${res.statusCode}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Booking Confirmed!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'UGX ${formatter.format(_finalTotal)} paid successfully',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isVenue
                      ? 'Duration: $_venueDays day${_venueDays > 1 ? "s" : ""}'
                      : _isLand
                      ? 'Land purchase completed'
                      : 'Duration: $_totalMonths month${_totalMonths > 1 ? "s" : ""}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🎉 You saved UGX ${formatter.format(_youSave)}!',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Close the success dialog
                    Navigator.pop(ctx);
                    // Navigate back to previous page after a short delay
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
    );
  }

  void _showComingSoon(String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$method coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildMonthsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rental Duration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Minimum package: $_minimumMonths month${_minimumMonths > 1 ? "s" : ""} ',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // Minimum months — fixed/locked
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.lock, size: 16, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                'Base: $_minimumMonths month${_minimumMonths > 1 ? "s" : ""} × UGX ${formatter.format(_pricePerMonth)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Extra months selector
        Row(
          children: [
            const Text(
              'Add extra months:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            IconButton(
              onPressed:
                  _extraMonths > 0
                      ? () => setState(() => _extraMonths--)
                      : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: _extraMonths > 0 ? Colors.orange : Colors.grey,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '$_extraMonths',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _extraMonths++),
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.orange,
            ),
          ],
        ),

        // Total months display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total duration:',
                style: TextStyle(color: Colors.green[800]),
              ),
              Text(
                '$_totalMonths month${_totalMonths > 1 ? "s" : ""}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension on _PropertyBookingPageState {
  Widget _buildNoPaymentMethods() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.orange[50],
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.orange[200]!),
    ),
    child: const Row(
      children: [
        Icon(Icons.info_outline, color: Colors.orange),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'No payment methods available yet. Please contact support.',
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    ),
  );
}
}

// ─── Payment Option Widget ───────────────────────────────
// ✅ Replace the entire _PaymentOption class
class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onSelected;
  final bool isSelected;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onSelected,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Card(
        elevation: isSelected ? 0 : 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: isSelected ? color.withOpacity(0.05) : Colors.white,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(isSelected ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? color : Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: color)
              : const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onSelected,
        ),
      ),
    );
  }
}
