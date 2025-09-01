import 'package:brickapp/models/product_model.dart';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/providers/p_filter_provider.dart';
import 'package:brickapp/providers/product_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final filteredProductProvider = Provider<List<PropertyModel>>((ref) {
  final productList = ref.watch(productProvider);
  final filter = ref.watch(filterProvider);

  if (filter == null) {
    return productList;
  }

  final from = filter.fromPrice;
  final to = filter.toPrice;

  return productList.where((product) {
    // Convert product.price to double first
    final productPrice = product.price;

    final matchesDescription =
        filter.selectedDescriptions.isEmpty ||
        filter.selectedDescriptions.any(
          (desc) =>
              product.description.toLowerCase().contains(desc.toLowerCase()),
        );

    final matchesPrice =
        (from == null || productPrice >= from) &&
        (to == null || productPrice <= to);

    final matchesAmenities = filter.selectedAmenities.entries.every((entry) {
      if (!entry.value) return true;
      return product.amenities.contains(entry.key);
    });

    return matchesDescription && matchesPrice && matchesAmenities;
  }).toList();
});
