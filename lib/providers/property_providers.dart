import 'dart:convert';
import 'package:brickapp/providers/search_and_query_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';
import '../utils/urls.dart';

// ─── Filter Model ─────────────────────────────────────────
class PropertyFilter {
  final String? propertyType;
  final String? listingType;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final String? purpose;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final List<String>? propertyTypes;
  final List<String>? amenities;

  const PropertyFilter({
    this.propertyType,
    this.listingType,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.purpose,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.propertyTypes,
    this.amenities,
  });

  bool get hasLocationFilter =>
      latitude != null && longitude != null && radiusKm != null;

  bool get hasAnyFilter =>
      minPrice != null ||
      maxPrice != null ||
      hasLocationFilter ||
      (propertyTypes?.isNotEmpty ?? false) ||
      (amenities?.isNotEmpty ?? false) ||
      bedrooms != null ||
      propertyType != null;

  PropertyFilter copyWith({
    String? propertyType,
    String? listingType,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? purpose,
    double? latitude,
    double? longitude,
    double? radiusKm,
    List<String>? propertyTypes,
    List<String>? amenities,
  }) {
    return PropertyFilter(
      propertyType: propertyType ?? this.propertyType,
      listingType: listingType ?? this.listingType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      bedrooms: bedrooms ?? this.bedrooms,
      purpose: purpose ?? this.purpose,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      amenities: amenities ?? this.amenities,
    );
  }
}

// ─── Filter Provider ──────────────────────────────────────
final propertyFilterProvider = StateProvider<PropertyFilter>(
  (ref) => const PropertyFilter(),
);

// ─── Main Properties Provider ─────────────────────────────
final propertiesProvider = FutureProvider.autoDispose<List<PropertyModel>>((
  ref,
) async {
  final filter = ref.watch(propertyFilterProvider);

  // ✅ Use nearby endpoint when location filter is active
  if (filter.hasLocationFilter) {
    final uri = Uri.parse(AppUrls.nearbyProperties(
      filter.latitude!,
      filter.longitude!,
      filter.radiusKm!,
    ));

    print('📍 Fetching nearby properties: $uri');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List list = data['properties'] ?? [];

      // ✅ Apply additional filters on top of location results
      return list
          .map((e) => PropertyModel.fromJson(e))
          .where((p) => _applyLocalFilters(p, filter))
          .toList();
    } else {
      throw Exception('Failed to load nearby properties');
    }
  }

  // ✅ Regular listing endpoint with query params
  final queryParams = <String, String>{};
  if (filter.propertyType != null) {
    queryParams['property_type'] = filter.propertyType!;
  }
  if (filter.propertyTypes != null && filter.propertyTypes!.isNotEmpty) {
    queryParams['property_type'] = filter.propertyTypes!.first;
  }
  if (filter.listingType != null) {
    queryParams['listing_type'] = filter.listingType!;
  }
  if (filter.minPrice != null) {
    queryParams['min_price'] = filter.minPrice.toString();
  }
  if (filter.maxPrice != null) {
    queryParams['max_price'] = filter.maxPrice.toString();
  }
  if (filter.bedrooms != null) {
    queryParams['bedrooms'] = filter.bedrooms.toString();
  }
  if (filter.purpose != null) {
    queryParams['purpose'] = filter.purpose!;
  }

  final uri = Uri.parse(AppUrls.properties)
      .replace(queryParameters: queryParams);

  print('📡 Fetching properties: $uri');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List list = data['properties'];
    return list
        .map((e) => PropertyModel.fromJson(e))
        .where((p) => _applyLocalFilters(p, filter))
        .toList();
  } else {
    throw Exception('Failed to load properties');
  }
});

// ✅ Local filter applied after fetching
bool _applyLocalFilters(PropertyModel p, PropertyFilter filter) {
  // Price filter
  if (filter.minPrice != null && (p.rentPrice ?? 0) < filter.minPrice!) {
    return false;
  }
  if (filter.maxPrice != null && (p.rentPrice ?? 0) > filter.maxPrice!) {
    return false;
  }

  // Bedrooms filter
  if (filter.bedrooms != null && filter.bedrooms! > 0) {
    if (p.bedrooms < filter.bedrooms!) return false;
  }

  // Property types filter (multiple selection)
  if (filter.propertyTypes != null && filter.propertyTypes!.isNotEmpty) {
    if (!filter.propertyTypes!.contains(p.propertyType)) return false;
  }

  // Amenities filter
  if (filter.amenities != null && filter.amenities!.isNotEmpty) {
    for (final amenity in filter.amenities!) {
      if (!p.amenities.map((a) => a.toLowerCase())
          .contains(amenity.toLowerCase())) {
        return false;
      }
    }
  }

  return true;
}

// ─── Search Filter Provider ───────────────────────────────
final filteredPropertiesProvider =
    Provider<AsyncValue<List<PropertyModel>>>((ref) {
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

// ─── My Listings Provider ─────────────────────────────────
final myListingsProvider =
    FutureProvider.autoDispose<List<PropertyModel>>((ref) async {
  throw UnimplementedError('Pass token when calling');
});

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