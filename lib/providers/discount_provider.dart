import 'package:hooks_riverpod/hooks_riverpod.dart';

final discountDialogShownProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);
