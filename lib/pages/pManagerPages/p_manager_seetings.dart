import 'dart:convert';
import 'package:brickapp/providers/stats_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Stats provider

class PaymentSettingsState {
  final bool mobileMoneyEnabled;
  final bool bankTransferEnabled;
  final bool cardPaymentEnabled;
  final bool hasChanges;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String branchCode;

  PaymentSettingsState({
    this.mobileMoneyEnabled = false,
    this.bankTransferEnabled = false,
    this.cardPaymentEnabled = false,
    this.hasChanges = false,
    this.bankName = '',
    this.accountNumber = '',
    this.accountHolder = '',
    this.branchCode = '',
  });

  PaymentSettingsState copyWith({
    bool? mobileMoneyEnabled,
    bool? bankTransferEnabled,
    bool? cardPaymentEnabled,
    bool? hasChanges,
    String? bankName,
    String? accountNumber,
    String? accountHolder,
    String? branchCode,
  }) {
    return PaymentSettingsState(
      mobileMoneyEnabled: mobileMoneyEnabled ?? this.mobileMoneyEnabled,
      bankTransferEnabled: bankTransferEnabled ?? this.bankTransferEnabled,
      cardPaymentEnabled: cardPaymentEnabled ?? this.cardPaymentEnabled,
      hasChanges: hasChanges ?? this.hasChanges,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolder: accountHolder ?? this.accountHolder,
      branchCode: branchCode ?? this.branchCode,
    );
  }
}

class PaymentSettingsNotifier extends StateNotifier<PaymentSettingsState> {
  PaymentSettingsNotifier() : super(PaymentSettingsState());

  void toggleMobileMoney(bool value) =>
      state = state.copyWith(mobileMoneyEnabled: value, hasChanges: true);

  void toggleBankTransfer(bool value) =>
      state = state.copyWith(bankTransferEnabled: value, hasChanges: true);

  void toggleCardPayment(bool value) =>
      state = state.copyWith(cardPaymentEnabled: value, hasChanges: true);

  void updateBankDetails({
    String? bankName,
    String? accountNumber,
    String? accountHolder,
    String? branchCode,
  }) {
    state = state.copyWith(
      bankName: bankName ?? state.bankName,
      accountNumber: accountNumber ?? state.accountNumber,
      accountHolder: accountHolder ?? state.accountHolder,
      branchCode: branchCode ?? state.branchCode,
      hasChanges: true,
    );
  }

  void applyChanges() => state = state.copyWith(hasChanges: false);
}

class PManagerSettings extends ConsumerWidget {
  const PManagerSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(userProvider).token ?? '';
    final statsAsync = ref.watch(managerStatsProvider(token));
    final paymentState = ref.watch(paymentSettingsProvider);
    final paymentNotifier = ref.read(paymentSettingsProvider.notifier);
    final formatter = NumberFormat('#,###');

    return PopScope(
      canPop: !paymentState.hasChanges,
      onPopInvoked: (bool didPop) {
        if (!didPop && paymentState.hasChanges) {
          _showUnsavedChangesDialog(context, ref);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manager Settings'),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (paymentState.hasChanges) {
                _showUnsavedChangesDialog(context, ref);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (paymentState.hasChanges)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _applyChanges(context, ref),
                tooltip: 'Save Changes',
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.refresh(managerStatsProvider(token)),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Stats Overview ───────────────────────
              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => Center(
                      child: Column(
                        children: [
                          Text('Failed to load stats: $e'),
                          TextButton(
                            onPressed:
                                () => ref.refresh(managerStatsProvider(token)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                data:
                    (stats) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Property stats
                        _buildSectionTitle('My Properties'),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Active',
                                '${stats['properties']['active']}',
                                Icons.home,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Pending',
                                '${stats['properties']['pending']}',
                                Icons.pending,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Inactive',
                                '${stats['properties']['inactive']}',
                                Icons.visibility_off,
                                Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Revenue stats
                        _buildSectionTitle('Revenue'),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Revenue',
                                'UGX ${formatter.format(double.tryParse(stats['revenue']['total_revenue'].toString()) ?? 0)}',
                                Icons.attach_money,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Net Earnings',
                                'UGX ${formatter.format(double.tryParse(stats['revenue']['net_revenue'].toString()) ?? 0)}',
                                Icons.trending_up,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Confirmed Bookings',
                                '${stats['bookings']['confirmed']}',
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Pending Bookings',
                                '${stats['bookings']['pending']}',
                                Icons.hourglass_empty,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Monthly revenue chart
                        if ((stats['monthly_revenue'] as List).isNotEmpty) ...[
                          _buildSectionTitle('Monthly Revenue'),
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                height: 250,
                                child: SfCartesianChart(
                                  primaryXAxis: const CategoryAxis(),
                                  legend: const Legend(isVisible: true),
                                  tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                  ),
                                  series: <CartesianSeries>[
                                    LineSeries<Map<String, dynamic>, String>(
                                      name: 'Revenue',
                                      dataSource:
                                          List<Map<String, dynamic>>.from(
                                            stats['monthly_revenue'],
                                          ),
                                      xValueMapper:
                                          (data, _) => data['month'].toString(),
                                      yValueMapper:
                                          (data, _) =>
                                              double.tryParse(
                                                data['revenue'].toString(),
                                              ) ??
                                              0,
                                      markerSettings: const MarkerSettings(
                                        isVisible: true,
                                      ),
                                      color: Colors.deepOrange,
                                    ),
                                    LineSeries<Map<String, dynamic>, String>(
                                      name: 'Payout',
                                      dataSource:
                                          List<Map<String, dynamic>>.from(
                                            stats['monthly_revenue'],
                                          ),
                                      xValueMapper:
                                          (data, _) => data['month'].toString(),
                                      yValueMapper:
                                          (data, _) =>
                                              double.tryParse(
                                                data['payout'].toString(),
                                              ) ??
                                              0,
                                      markerSettings: const MarkerSettings(
                                        isVisible: true,
                                      ),
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Recent bookings
                        if ((stats['recent_bookings'] as List).isNotEmpty) ...[
                          _buildSectionTitle('Recent Bookings'),
                          Card(
                            elevation: 2,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  (stats['recent_bookings'] as List).length,
                              separatorBuilder:
                                  (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final booking =
                                    stats['recent_bookings'][index]
                                        as Map<String, dynamic>;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        booking['status'] == 'confirmed'
                                            ? Colors.green
                                            : Colors.orange,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    booking['client_name'] ?? 'Client',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${booking['property_type'] ?? ''} • ${booking['address'] ?? ''}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'UGX ${formatter.format(double.tryParse(booking['total_price'].toString()) ?? 0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              booking['status'] == 'confirmed'
                                                  ? Colors.green[50]
                                                  : Colors.orange[50],
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          booking['status']
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color:
                                                booking['status'] == 'confirmed'
                                                    ? Colors.green
                                                    : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
              ),

              // ─── Payment Methods ──────────────────────
              _buildSectionTitle('Payment Methods'),
              _buildPaymentMethodsSection(paymentState, paymentNotifier),
              const SizedBox(height: 16),

              if (paymentState.bankTransferEnabled) ...[
                _buildBankDetailsSection(
                  context,
                  paymentState,
                  paymentNotifier,
                ),
                const SizedBox(height: 16),
              ],

              // Apply Changes Button
              const SizedBox(height: 16),
              _buildApplyChangesButton(context, paymentState, ref),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection(
    PaymentSettingsState state,
    PaymentSettingsNotifier notifier,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPaymentOption(
              icon: Icons.phone_android,
              title: 'Mobile Money',
              subtitle: 'MTN & Airtel Money',
              value: state.mobileMoneyEnabled,
              onChanged: notifier.toggleMobileMoney,
            ),
            const Divider(),
            _buildPaymentOption(
              icon: Icons.account_balance,
              title: 'Bank Transfer',
              subtitle: 'Direct bank payment',
              value: state.bankTransferEnabled,
              onChanged: notifier.toggleBankTransfer,
            ),
            const Divider(),
            _buildPaymentOption(
              icon: Icons.credit_card,
              title: 'Credit/Debit Card',
              subtitle: 'Visa & Mastercard',
              value: state.cardPaymentEnabled,
              onChanged: notifier.toggleCardPayment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepOrange),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.deepOrange,
      ),
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildBankDetailsSection(
    BuildContext context,
    PaymentSettingsState state,
    PaymentSettingsNotifier notifier,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text(
                  'Bank Account Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.bankName,
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
              ),
              onChanged: (v) => notifier.updateBankDetails(bankName: v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.accountNumber,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => notifier.updateBankDetails(accountNumber: v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.accountHolder,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (v) => notifier.updateBankDetails(accountHolder: v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.branchCode,
              decoration: const InputDecoration(
                labelText: 'Branch Code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
              ),
              onChanged: (v) => notifier.updateBankDetails(branchCode: v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyChangesButton(
    BuildContext context,
    PaymentSettingsState state,
    WidgetRef ref,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.hasChanges ? () => _applyChanges(context, ref) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Save Payment Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnsavedChangesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text('Unsaved Changes'),
              ],
            ),
            content: const Text(
              'You have unsaved changes. Leave without saving?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.deepOrange),
                child: const Text('Leave'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _applyChanges(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save & Leave'),
              ),
            ],
          ),
    );
  }

  void _applyChanges(BuildContext context, WidgetRef ref) {
    final state = ref.read(paymentSettingsProvider);
    final notifier = ref.read(paymentSettingsProvider.notifier);

    if (state.bankTransferEnabled &&
        (state.bankName.isEmpty ||
            state.accountNumber.isEmpty ||
            state.accountHolder.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required bank details'),
          backgroundColor: Colors.deepOrange,
        ),
      );
      return;
    }

    // TODO: Save payment settings to backend when payment table is added
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment settings saved!'),
        backgroundColor: Colors.green,
      ),
    );

    notifier.applyChanges();
  }
}
