import 'dart:convert';
import 'package:brickapp/providers/search_and_query_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';
import '../utils/urls.dart';

// Filter state
class PropertyFilter {
  final String? propertyType;
  final String? listingType;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final String? purpose;

  const PropertyFilter({
    this.propertyType,
    this.listingType,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.purpose,
  });

  PropertyFilter copyWith({
    String? propertyType,
    String? listingType,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? purpose,
  }) {
    return PropertyFilter(
      propertyType: propertyType ?? this.propertyType,
      listingType: listingType ?? this.listingType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      bedrooms: bedrooms ?? this.bedrooms,
      purpose: purpose ?? this.purpose,
    );
  }
}

// Filter provider
final propertyFilterProvider = StateProvider<PropertyFilter>(
  (ref) => const PropertyFilter(),
);
final filteredPropertiesProvider = Provider<AsyncValue<List<PropertyModel>>>((
  ref,
) {
  final propertiesAsync = ref.watch(propertiesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return propertiesAsync.whenData((properties) {
    if (query.isEmpty) return properties;

    return properties.where((property) {
      final title = property.propertyType.toLowerCase();
      final location = (property.address ?? '').toLowerCase();
      final description = (property.description ?? '').toLowerCase();

      return title.contains(query) ||
          location.contains(query) ||
          description.contains(query);
    }).toList();
  });
});
// Properties provider — fetches from backend
final propertiesProvider = FutureProvider.autoDispose<List<PropertyModel>>((
  ref,
) async {
  final filter = ref.watch(propertyFilterProvider);

  // Build query string
  final queryParams = <String, String>{};
  if (filter.propertyType != null)
    queryParams['property_type'] = filter.propertyType!;
  if (filter.listingType != null)
    queryParams['listing_type'] = filter.listingType!;
  if (filter.minPrice != null)
    queryParams['min_price'] = filter.minPrice.toString();
  if (filter.maxPrice != null)
    queryParams['max_price'] = filter.maxPrice.toString();
  if (filter.bedrooms != null)
    queryParams['bedrooms'] = filter.bedrooms.toString();
  if (filter.purpose != null) queryParams['purpose'] = filter.purpose!;

  final uri = Uri.parse(
    AppUrls.properties,
  ).replace(queryParameters: queryParams);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List list = data['properties'];
    if (list.isNotEmpty) {
      print('🖼️ THUMBNAIL: ${list[0]['thumbnail']}');
      print('🖼️ FULL URL: http://10.0.2.2:3000/${list[0]['thumbnail']}');
    }
    return list.map((e) => PropertyModel.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load properties');
  }
});

// My listings provider — for property managers
final myListingsProvider = FutureProvider.autoDispose<List<PropertyModel>>((
  ref,
) async {
  // Token will be passed from the widget
  throw UnimplementedError('Pass token when calling');
});

// Family provider that accepts token
final myListingsFamilyProvider = FutureProvider.autoDispose
    .family<List<PropertyModel>, String>((ref, token) async {
      final response = await http.get(
        Uri.parse(AppUrls.myListings),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['properties'];
        return list.map((e) => PropertyModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load listings');
      }
    });

// Properties by owner
final ownerPropertiesFamilyProvider = FutureProvider.autoDispose
    .family<List<PropertyModel>, int>((ref, userId) async {
      final response = await http.get(
        Uri.parse('${AppUrls.properties}?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['properties'];
        return list.map((e) => PropertyModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load owner properties');
      }
    });
