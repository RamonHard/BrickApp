class PaymentSettingsState {
  final bool mobileMoneyEnabled;
  final bool bankTransferEnabled;
  final bool cardPaymentEnabled;
  final bool hasChanges;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String branchCode;
  final String mobileMoneyNumber;
  final String mobileMoneyProvider;

  PaymentSettingsState({
    this.mobileMoneyEnabled = false,
    this.bankTransferEnabled = false,
    this.cardPaymentEnabled = false,
    this.hasChanges = false,
    this.bankName = '',
    this.accountNumber = '',
    this.accountHolder = '',
    this.branchCode = '',
    this.mobileMoneyNumber = '',
    this.mobileMoneyProvider = 'MTN',
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
    String? mobileMoneyNumber,
    String? mobileMoneyProvider,
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
      mobileMoneyNumber: mobileMoneyNumber ?? this.mobileMoneyNumber,
      mobileMoneyProvider: mobileMoneyProvider ?? this.mobileMoneyProvider,
    );
  }
}