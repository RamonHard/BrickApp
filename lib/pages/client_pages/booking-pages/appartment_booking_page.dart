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
  }

  Future<void> _loadSettings() async {
    try {
      print('🌐 Fetching public settings...');

      final res = await http.get(
        Uri.parse('${AppUrls.baseUrl}/settings/public'),
      );

      print('📡 Status: ${res.statusCode}');
      print('📡 Body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final settings = List<Map<String, dynamic>>.from(data['settings']);

        for (final s in settings) {
          print('⚙️ ${s['key']} = ${s['value']}');
          if (s['key'] == 'property_commission_percent') {
            _commissionPercent = double.tryParse(s['value'].toString()) ?? 10.0;
          }
          if (s['key'] == 'client_discount_percent') {
            _clientDiscountPercent =
                double.tryParse(s['value'].toString()) ?? 8.0;
          }
          if (s['key'] == 'commission_months') {
            _commissionableMonthsLimit =
                int.tryParse(s['value'].toString()) ?? 3;
          }
        }

        print('✅ Commission: $_commissionPercent%');
        print('✅ Discount: $_clientDiscountPercent%');
        print('✅ Commission months: $_commissionableMonthsLimit');
      }
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print('❌ Stack: $stackTrace');
    }
    setState(() => _settingsLoaded = true);
  }

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

  double get _baseTotal => _pricePerMonth * _totalMonths;

  double get _commissionableAmount => _pricePerMonth * _commissionableMonths;

  double get _platformCommission =>
      _commissionableAmount * (_commissionPercent / 100);

  double get _clientDiscount =>
      _platformCommission * (_clientDiscountPercent / 100);

  double get _finalTotal => _baseTotal - _clientDiscount;

  double get _youSave => _clientDiscount;

  int get _commissionableMonths =>
      _totalMonths < _commissionableMonthsLimit
          ? _totalMonths
          : _commissionableMonthsLimit;

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
                  _buildMonthsSelector(),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildPriceBreakdown(),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _PaymentOption(
                    title: 'Mobile Money',
                    subtitle: 'MTN & Airtel Money',
                    icon: Icons.phone_android,
                    color: Colors.yellow[700]!,
                    onSelected: _showMobileMoneyFlow,
                  ),
                  const SizedBox(height: 8),
                  _PaymentOption(
                    title: 'Bank Transfer',
                    subtitle: 'Direct bank payment',
                    icon: Icons.account_balance,
                    color: Colors.brown,
                    onSelected: () => _showComingSoon('Bank Transfer'),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOption(
                    title: 'Visa / Mastercard',
                    subtitle: 'Credit or debit card',
                    icon: Icons.credit_card,
                    color: Colors.blue,
                    onSelected: () => _showComingSoon('Card Payment'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
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
          'Minimum package: $_minimumMonths month${_minimumMonths > 1 ? 's' : ''} ',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
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
                'Base: $_minimumMonths month${_minimumMonths > 1 ? 's' : ''} × UGX ${formatter.format(_pricePerMonth)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
                '$_totalMonths month${_totalMonths > 1 ? 's' : ''}',
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

  Widget _buildPriceBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildPriceRow(
          'Price per month',
          'UGX ${formatter.format(_pricePerMonth)}',
        ),
        _buildPriceRow('Total months', '$_totalMonths months'),
        _buildPriceRow('Base total', 'UGX ${formatter.format(_baseTotal)}'),
        const Divider(height: 20),
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
                'Total to Pay',
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

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
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
  Future<void> _processBooking(String phone) async {
    // Check if already navigating to prevent duplicate calls
    if (_isNavigating) return;
    _isNavigating = true;

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
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

      final startDate = DateTime.now();
      final endDate = DateTime(
        startDate.year,
        startDate.month + _totalMonths,
        startDate.day,
      );

      final res = await http.post(
        Uri.parse(AppUrls.bookProperty),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'property_id': widget.productModel.id,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'total_price': _finalTotal,
          'total_months': _totalMonths,
          'payment_method': 'mobile_money',
          'payment_phone': phone,
          'platform_commission': _platformCommission,
          'client_discount': _youSave,
        }),
      );

      final data = jsonDecode(res.body);

      // Close processing dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (res.statusCode == 200 && data['status'] == true) {
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Booking failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close processing dialog on error
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      _isNavigating = false;
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
                  'Duration: $_totalMonths month${_totalMonths > 1 ? 's' : ''}',
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
}

// ─── Payment Option Widget ───────────────────────────────
class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onSelected;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onSelected,
      ),
    );
  }
}
