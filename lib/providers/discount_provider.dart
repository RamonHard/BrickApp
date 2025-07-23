import 'package:flutter_riverpod/flutter_riverpod.dart';

final discountPercentageProvider = StateProvider<double>((ref) => 8.0);

final discountedPriceProvider = Provider.family<double, double>((
  ref,
  originalPrice,
) {
  final percentage = ref.watch(discountPercentageProvider);
  return originalPrice - (originalPrice * percentage / 100);
});
