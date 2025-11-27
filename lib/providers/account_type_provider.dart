import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountType { transportServiceProvider, propertyOwner, none }

class AccountTypeNotifier extends StateNotifier<AccountType> {
  AccountTypeNotifier() : super(AccountType.none);

  void setAccountType(AccountType type) {
    state = type;
  }

  void reset() {
    state = AccountType.none;
  }
}

final accountTypeProvider =
    StateNotifierProvider<AccountTypeNotifier, AccountType>(
      (ref) => AccountTypeNotifier(),
    );
