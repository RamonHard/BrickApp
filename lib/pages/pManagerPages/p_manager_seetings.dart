import 'dart:convert';
import 'package:brickapp/pages/pManagerPages/manager_stats.dart';
import 'package:brickapp/pages/pManagerPages/payment_settings.dart';
import 'package:brickapp/providers/p_manager_State_provider.dart';
import 'package:brickapp/providers/stats_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PManagerSettings extends ConsumerStatefulWidget {
  const PManagerSettings({super.key});
  @override
  ConsumerState<PManagerSettings> createState() => _PManagerSettingsState();
}

class _PManagerSettingsState extends ConsumerState<PManagerSettings> {
  // Payment method state
  bool _mobileMoneyEnabled = false;
  String _mobileMoneyNumber = '';
  String _mobileMoneyProvider = 'MTN';
  bool _bankEnabled = false;
  String _bankName = '';
  String _accountNumber = '';
  String _accountHolder = '';
  String _branchCode = '';
  bool _hasChanges = false;
  bool _isSaving = false;
  bool _isLoadingMethods = true;

  // Wallet state
  double _withdrawableBalance = 0;
  double _lockedBalance = 0;
  bool _isLoadingWallet = true;

  final _mobileNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _branchCodeController = TextEditingController();
double _pendingReleaseBalance = 0;

  final formatter = NumberFormat('#,###');
  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _loadWallet();
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _branchCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final token = ref.read(userProvider).token ?? '';
      final res = await http.get(
        Uri.parse(AppUrls.paymentMethods),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final methods = data['methods'];
        if (methods != null) {
          setState(() {
            _mobileMoneyEnabled = methods['mobile_money_enabled'] ?? false;
            _mobileMoneyNumber = methods['mobile_money_number'] ?? '';
            _mobileMoneyProvider = methods['mobile_money_provider'] ?? 'MTN';
            _bankEnabled = methods['bank_enabled'] ?? false;
            _bankName = methods['bank_name'] ?? '';
            _accountNumber = methods['bank_account_number'] ?? '';
            _accountHolder = methods['bank_account_holder'] ?? '';
            _branchCode = methods['bank_branch_code'] ?? '';
            _mobileNumberController.text = _mobileMoneyNumber;
            _bankNameController.text = _bankName;
            _accountNumberController.text = _accountNumber;
            _accountHolderController.text = _accountHolder;
            _branchCodeController.text = _branchCode;
          });
        }
      }
    } catch (e) {
      print('❌ Load payment methods error: $e');
    }
    setState(() => _isLoadingMethods = false);
  }

  Future<void> _loadWallet() async {
    try {
      final token = ref.read(userProvider).token ?? '';
      final res = await http.get(
        Uri.parse(AppUrls.wallet),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _pendingReleaseBalance = double.tryParse(
  data['wallet']['pending_release_balance']?.toString() ?? '0',
) ?? 0;
        setState(() {
          _withdrawableBalance = double.tryParse(
              data['wallet']['withdrawable_balance'].toString()) ?? 0;
          _lockedBalance = double.tryParse(
              data['wallet']['locked_balance'].toString()) ?? 0;
        });
      }
    } catch (e) {
      print('❌ Load wallet error: $e');
    }
    setState(() => _isLoadingWallet = false);
  }

  Future<void> _savePaymentMethods() async {
    if (_bankEnabled && (_bankNameController.text.isEmpty ||
        _accountNumberController.text.isEmpty ||
        _accountHolderController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all bank details'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_mobileMoneyEnabled && _mobileNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your mobile money number'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final token = ref.read(userProvider).token ?? '';
      final res = await http.patch(
        Uri.parse(AppUrls.paymentMethods),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobile_money_enabled': _mobileMoneyEnabled,
          'mobile_money_number': _mobileNumberController.text.trim(),
          'mobile_money_provider': _mobileMoneyProvider,
          'bank_enabled': _bankEnabled,
          'bank_name': _bankNameController.text.trim(),
          'bank_account_number': _accountNumberController.text.trim(),
          'bank_account_holder': _accountHolderController.text.trim(),
          'bank_branch_code': _branchCodeController.text.trim(),
        }),
      );
      if (res.statusCode == 200) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment methods saved!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isSaving = false);
  }

// ✅ Add this method to _PManagerSettingsState
Future<double> _getWithdrawalCharge(double amount) async {
  try {
    final res = await http.get(
      Uri.parse('${AppUrls.baseUrl}/settings/public'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final settings = data['settings'] as Map<String, dynamic>;
      for (int i = 1; i <= 10; i++) {
        final min = double.tryParse(settings['withdrawal_charge_tier_${i}_min']?.toString() ?? '') ?? -1;
        final max = double.tryParse(settings['withdrawal_charge_tier_${i}_max']?.toString() ?? '') ?? -1;
        final fee = double.tryParse(settings['withdrawal_charge_tier_${i}_fee']?.toString() ?? '') ?? 0;
        if (min >= 0 && max >= 0 && amount >= min && amount <= max) {
          return fee;
        }
      }
    }
  } catch (e) {
    print('Error getting charge: $e');
  }
  return 0;
}

  Future<void> _requestWithdrawal() async {
  if (_withdrawableBalance <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No balance available to withdraw')),
    );
    return;
  }

  // Load platform payment methods
  Map<String, dynamic>? platformMethods;
  try {
    final res = await http.get(Uri.parse(AppUrls.platformPaymentMethods));
    if (res.statusCode == 200) {
      platformMethods = jsonDecode(res.body)['methods'];
    }
  } catch (e) {
    print('Error loading methods: $e');
  }

  if (!mounted) return;

  // Build available methods list
  final List<Map<String, String>> availableMethods = [];
  if (platformMethods != null) {
    if (platformMethods['payment_mobile_money_enabled'] == 'true') {
      availableMethods.add({
        'id': 'mobile_money',
        'label':
            '${platformMethods['payment_mobile_money_provider']} Money — ${platformMethods['payment_mobile_money_number']}',
      });
    }
    if (platformMethods['payment_airtel_enabled'] == 'true') {
      availableMethods.add({
        'id': 'airtel',
        'label':
            'Airtel Money — ${platformMethods['payment_airtel_number']}',
      });
    }
    if (platformMethods['payment_bank_enabled'] == 'true') {
      availableMethods.add({
        'id': 'bank',
        'label':
            '${platformMethods['payment_bank_name']} — ${platformMethods['payment_bank_account_number']}',
      });
    }
  }

  if (availableMethods.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No payment methods available. Contact admin.'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  // Dialog state
  String? selectedMethod = availableMethods.first['id'];
  final passwordController = TextEditingController();
  final amountController = TextEditingController(
      text: _withdrawableBalance.toStringAsFixed(0));
  bool obscurePassword = true;
  double dialogCharge = 0;
  double dialogNet = _withdrawableBalance;

  // Pre-calculate charge for default amount
  dialogCharge = await _getWithdrawalCharge(_withdrawableBalance);
  dialogNet = _withdrawableBalance - dialogCharge;

  if (!mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        // Listen to amount changes
        amountController.removeListener(() {});
        amountController.addListener(() async {
          final amt = double.tryParse(amountController.text) ?? 0;
          if (amt > 0) {
            final charge = await _getWithdrawalCharge(amt);
            setDialogState(() {
              dialogCharge = charge;
              dialogNet = amt - charge;
            });
          }
        });

        return AlertDialog(
          title: const Text('Request Withdrawal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Available balance ──────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
  children: [
    Expanded(
      child: _buildWalletCard(
        'Available Balance',
        'UGX ${formatter.format(_withdrawableBalance)}',
        Colors.green,
          'Your earnings after all deductions'
      ),
    ),

    if (_pendingReleaseBalance > 0) ...[
      const SizedBox(width: 12),
      Expanded(
        child: _buildWalletCard(
          '⏳ Pending Release',
          'UGX ${formatter.format(_pendingReleaseBalance)}',
          Colors.purple,
           'Released when property is fully approved',
        ),
      ),
    ],
  ],
)
                ),
                const SizedBox(height: 16),

                // ─── Amount ─────────────────────────────
                const Text('Amount to Withdraw',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: 'UGX ',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    hintText: 'Enter amount',
                  ),
                ),

                // ─── Charge preview ──────────────────────
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Withdrawal amount:'),
                          Text(
                            'UGX ${NumberFormat('#,###').format(double.tryParse(amountController.text) ?? 0)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Withdrawal charge:',
                              style:
                                  TextStyle(color: Colors.orange)),
                          Text(
                            '- UGX ${NumberFormat('#,###').format(dialogCharge)}',
                            style: const TextStyle(
                                color: Colors.orange),
                          ),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('You receive:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                          Text(
                            'UGX ${NumberFormat('#,###').format(dialogNet)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Payment method ──────────────────────
                const Text('Withdraw To',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ...availableMethods.map((m) => RadioListTile<String>(
                      value: m['id']!,
                      groupValue: selectedMethod,
                      title: Text(m['label']!,
                          style: const TextStyle(fontSize: 13)),
                      activeColor: Colors.deepOrange,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) =>
                          setDialogState(() => selectedMethod = v),
                    )),

                const SizedBox(height: 16),

                // ─── Password ────────────────────────────
                const Text('Confirm with Password',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your login password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setDialogState(
                          () => obscurePassword = !obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🔒 Your password is required to authorize this withdrawal.',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          actions: [
             
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green),
              child: const Text('Submit Withdrawal',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ),
  );

  if (confirmed != true || !mounted) return;
  if (passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Password is required'),
          backgroundColor: Colors.red),
    );
    return;
  }

  setState(() => _isSaving = true);
  try {
    final token = ref.read(userProvider).token ?? '';
    final amount =
        double.tryParse(amountController.text) ?? _withdrawableBalance;

    final selectedMethodData = availableMethods
        .firstWhere((m) => m['id'] == selectedMethod);

    final res = await http.post(
      Uri.parse(AppUrls.withdrawalRequest),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'payment_method': selectedMethod,
        'payment_number':
            platformMethods?['payment_${selectedMethod}_number'] ?? '',
        'payment_name':
            platformMethods?['payment_${selectedMethod}_name'] ?? '',
        'password': passwordController.text,
      }),
    );

    if (!mounted) return;
    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      setState(() => _withdrawableBalance -= amount);
      final details = data['details'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Withdrawal of UGX ${NumberFormat('#,###').format(details['amount_requested'])} processed! '
            'Charge: UGX ${NumberFormat('#,###').format(details['charge'])}. '
            'Net: UGX ${NumberFormat('#,###').format(details['net_amount'])}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
      _loadWallet(); // refresh wallet
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
  setState(() => _isSaving = false);
}

  @override
  Widget build(BuildContext context) {
  // ✅ Use the auto provider that gets token internally
  final statsAsync = ref.watch(managerStatsAutoProvider);
  final formatter = NumberFormat('#,###');

  return Scaffold(
    appBar: AppBar(
      title: const Text('Manager Settings'),
      backgroundColor: Colors.deepOrange,
      foregroundColor: Colors.white,
      actions: [
        if (_hasChanges)
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePaymentMethods,
            tooltip: 'Save',
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.refresh(managerStatsAutoProvider);
            _loadWallet();
          },
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── WALLET SECTION ───────────────────────
_buildSectionTitle('💰 My Wallet'),
_isLoadingWallet
    ? const Center(child: CircularProgressIndicator())
    : Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildWalletCard(
                      '✅ Ready to Withdraw',
                      'UGX ${formatter.format(_withdrawableBalance)}',
                      Colors.green,
                      'Your earnings after all deductions',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildWalletCard(
                      '🔒 Awaiting Client Confirmation',
                      'UGX ${formatter.format(_lockedBalance)}',
                      Colors.orange,
                      'Released when client confirms visit',
                    ),
                  ),
                ],
              ),
              if (_pendingReleaseBalance > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildWalletCard(
                        '⏳ Pending Release',
                        'UGX ${formatter.format(_pendingReleaseBalance)}',
                        Colors.purple,
                        'Released when property is fully approved',
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _withdrawableBalance > 0
                      ? _requestWithdrawal
                      : null,
                  icon: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Withdraw UGX ${formatter.format(_withdrawableBalance)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (_lockedBalance > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_clock,
                        color: Colors.orange[700],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'UGX ${formatter.format(_lockedBalance)} is locked until clients confirm property visits.',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
const SizedBox(height: 24),

          // ─── STATS SECTION ────────────────────────
          _buildSectionTitle('📊 My Statistics'),
          
          // ✅ Use the auto provider
          statsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Loading statistics...'),
                  ],
                ),
              ),
            ),
            error: (e, stack) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[400], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load stats',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.toString(),
                    style: TextStyle(color: Colors.red[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      ref.refresh(managerStatsAutoProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (stats) {
              // Debug print
              print('📊 Stats data in UI: $stats');
              
              // Safely get values with fallbacks
              final totalProps = stats['total_properties'] ?? 0;
              final activeProps = stats['active_properties'] ?? 0;
              final pendingProps = stats['pending_properties'] ?? 0;
              final inactiveProps = stats['inactive_properties'] ?? 0;
              final totalViews = stats['total_views'] ?? 0;
              final totalBookings = stats['total_bookings'] ?? 0;
              final totalRevenue = stats['total_revenue'] ?? 0.0;
              final avgRating = stats['average_rating'] ?? 0.0;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Property Status Cards ──────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Properties',
                          '$totalProps',
                          Icons.home_work,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Active',
                          '$activeProps',
                          Icons.home,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          '$pendingProps',
                          Icons.pending,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // ─── Views & Bookings ──────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Views',
                          '$totalViews',
                          Icons.visibility,
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Total Bookings',
                          '$totalBookings',
                          Icons.calendar_today,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Avg Rating',
                          avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
                          Icons.star,
                          Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // ─── Revenue ──────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildStatCard(
                          'Total Revenue',
                          'UGX ${formatter.format(totalRevenue)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Inactive',
                          '$inactiveProps',
                          Icons.visibility_off,
                          Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // ─── View Detailed Stats Button ────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManagerStatsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart, color: Colors.white),
                      label: const Text(
                        'View Detailed Statistics',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(String title, String amount, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: color,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
              color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _buildStatCard(String title, String value, IconData icon, Color color) =>
      Card(elevation: 2, child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
              color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ]),
      ));
}