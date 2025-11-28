// providers/account_providers.dart
import 'package:brickapp/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountTypeNotifier extends StateNotifier<AccountType> {
  AccountTypeNotifier() : super(AccountType.regular);

  void setAccountType(AccountType type) {
    state = type;
  }

  void reset() {
    state = AccountType.regular;
  }
}

final accountTypeProvider =
    StateNotifierProvider<AccountTypeNotifier, AccountType>(
      (ref) => AccountTypeNotifier(),
    );

// Simple user provider to store basic user data
