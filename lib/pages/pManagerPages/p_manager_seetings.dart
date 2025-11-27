import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Provider for payment settings state
final paymentSettingsProvider =
    StateNotifierProvider<PaymentSettingsNotifier, PaymentSettingsState>((ref) {
      return PaymentSettingsNotifier();
    });

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

  void toggleMobileMoney(bool value) {
    state = state.copyWith(mobileMoneyEnabled: value, hasChanges: true);
  }

  void toggleBankTransfer(bool value) {
    state = state.copyWith(bankTransferEnabled: value, hasChanges: true);
  }

  void toggleCardPayment(bool value) {
    state = state.copyWith(cardPaymentEnabled: value, hasChanges: true);
  }

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

  void applyChanges() {
    state = state.copyWith(hasChanges: false);
  }

  void resetChanges() {
    state = state.copyWith(hasChanges: false);
  }
}

class PManagerSettings extends ConsumerWidget {
  const PManagerSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentSettingsProvider);
    final paymentNotifier = ref.read(paymentSettingsProvider.notifier);

    return PopScope(
      canPop: !paymentState.hasChanges,
      onPopInvoked: (bool didPop) {
        if (!didPop && paymentState.hasChanges) {
          _showUnsavedChangesDialog(context, ref);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Settings'),
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
                tooltip: 'Apply Changes',
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Methods Section
              _buildPaymentMethodsSection(paymentState, paymentNotifier),
              const SizedBox(height: 24),

              // Conditionally show Bank Details Form if Bank Transfer is enabled
              if (paymentState.bankTransferEnabled) ...[
                _buildBankDetailsSection(
                  context,
                  paymentState,
                  paymentNotifier,
                ),
                const SizedBox(height: 24),
              ],

              // Transaction Insights Section
              _buildTransactionInsightsSection(),
              const SizedBox(height: 24),

              // Account Visits Analytics Section
              _buildVisitsAnalyticsSection(),

              // Apply Changes Button
              const SizedBox(height: 32),
              _buildApplyChangesButton(context, paymentState, ref),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnsavedChangesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text('Unsaved Changes'),
            ],
          ),
          content: const Text(
            'You have unsaved changes. Are you sure you want to leave without applying them?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back
              },
              style: TextButton.styleFrom(foregroundColor: Colors.deepOrange),
              child: const Text('Leave'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _applyChanges(context, ref); // Apply changes first
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply & Leave'),
            ),
          ],
        );
      },
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              icon: Icons.phone_android,
              title: 'Mobile Money',
              subtitle: 'Receive payments via Mobile Money',
              value: state.mobileMoneyEnabled,
              onChanged: (value) => notifier.toggleMobileMoney(value),
            ),
            const Divider(),
            _buildPaymentOption(
              icon: Icons.account_balance,
              title: 'Bank Transfer',
              subtitle: 'Receive payments directly to your bank',
              value: state.bankTransferEnabled,
              onChanged: (value) => notifier.toggleBankTransfer(value),
            ),
            const Divider(),
            _buildPaymentOption(
              icon: Icons.credit_card,
              title: 'Credit/Debit Card',
              subtitle: 'Accept card payments',
              value: state.cardPaymentEnabled,
              onChanged: (value) => notifier.toggleCardPayment(value),
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
      onTap: () {
        onChanged(!value);
      },
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
                Icon(Icons.account_balance, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text(
                  'Bank Account Details',
                  style: TextStyle(
                    fontSize: 18,
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
              onChanged: (value) => notifier.updateBankDetails(bankName: value),
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
              onChanged:
                  (value) => notifier.updateBankDetails(accountNumber: value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.accountHolder,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged:
                  (value) => notifier.updateBankDetails(accountHolder: value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.branchCode,
              decoration: const InputDecoration(
                labelText: 'Branch Code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
              ),
              onChanged:
                  (value) => notifier.updateBankDetails(branchCode: value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _saveBankDetails(context, state);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Save Bank Details'),
              ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Apply Changes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _applyChanges(BuildContext context, WidgetRef ref) {
    final state = ref.read(paymentSettingsProvider);
    final notifier = ref.read(paymentSettingsProvider.notifier);

    // Validate bank details if bank transfer is enabled
    if (state.bankTransferEnabled &&
        (state.bankName.isEmpty ||
            state.accountNumber.isEmpty ||
            state.accountHolder.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required bank details'),
          backgroundColor: Colors.deepOrange,
        ),
      );
      return;
    }

    // Apply all changes logic here
    // This is where you would save all settings to your backend/database

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All changes applied successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Reset changes flag
    notifier.applyChanges();

    // Print current settings (for debugging)
    print('Payment Settings Applied:');
    print('Mobile Money: ${state.mobileMoneyEnabled}');
    print('Bank Transfer: ${state.bankTransferEnabled}');
    print('Card Payment: ${state.cardPaymentEnabled}');
    if (state.bankTransferEnabled) {
      print('Bank Name: ${state.bankName}');
      print('Account Number: ${state.accountNumber}');
      print('Account Holder: ${state.accountHolder}');
      print('Branch Code: ${state.branchCode}');
    }
  }

  void _saveBankDetails(BuildContext context, PaymentSettingsState state) {
    // Validate bank details
    if (state.bankName.isEmpty ||
        state.accountNumber.isEmpty ||
        state.accountHolder.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required bank details'),
          backgroundColor: Colors.deepOrange,
        ),
      );
      return;
    }

    // Save bank details logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bank details saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildTransactionInsightsSection() {
    // Sample transaction data
    final List<TransactionData> transactionData = [
      TransactionData('Jan', 1200, 800),
      TransactionData('Feb', 1500, 1100),
      TransactionData('Mar', 1800, 1300),
      TransactionData('Apr', 2000, 1500),
      TransactionData('May', 2200, 1700),
      TransactionData('Jun', 2500, 1900),
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total Revenue', '\$11,200', Icons.attach_money),
                _buildStatCard('Pending', '\$1,500', Icons.pending),
                _buildStatCard('This Month', '\$2,500', Icons.trending_up),
              ],
            ),
            const SizedBox(height: 20),

            // Transaction Chart
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(text: 'Monthly Transactions'),
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  LineSeries<TransactionData, String>(
                    name: 'Revenue',
                    dataSource: transactionData,
                    xValueMapper: (TransactionData data, _) => data.month,
                    yValueMapper: (TransactionData data, _) => data.revenue,
                    markerSettings: const MarkerSettings(isVisible: true),
                    color: Colors.deepOrange,
                  ),
                  LineSeries<TransactionData, String>(
                    name: 'Payouts',
                    dataSource: transactionData,
                    xValueMapper: (TransactionData data, _) => data.month,
                    yValueMapper: (TransactionData data, _) => data.payouts,
                    markerSettings: const MarkerSettings(isVisible: true),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitsAnalyticsSection() {
    // Sample visits data
    final List<VisitsData> visitsData = [
      VisitsData('Mon', 45),
      VisitsData('Tue', 52),
      VisitsData('Wed', 48),
      VisitsData('Thu', 60),
      VisitsData('Fri', 55),
      VisitsData('Sat', 35),
      VisitsData('Sun', 25),
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Visits Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total Visits', '320', Icons.people),
                _buildStatCard('Avg Daily', '46', Icons.timeline),
                _buildStatCard('Growth', '+12%', Icons.trending_up),
              ],
            ),
            const SizedBox(height: 20),

            // Visits Chart
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(text: 'Weekly Visits Trend'),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries<VisitsData, String>(
                    dataSource: visitsData,
                    xValueMapper: (VisitsData data, _) => data.day,
                    yValueMapper: (VisitsData data, _) => data.visits,
                    color: Colors.deepOrange,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepOrange, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Data models for charts
class TransactionData {
  final String month;
  final double revenue;
  final double payouts;

  TransactionData(this.month, this.revenue, this.payouts);
}

class VisitsData {
  final String day;
  final int visits;

  VisitsData(this.day, this.visits);
}
