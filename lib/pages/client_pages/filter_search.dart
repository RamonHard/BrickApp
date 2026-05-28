import 'package:brickapp/pages/client_pages/location_picker_page.dart';
import 'package:brickapp/pages/pManagerPages/map_location_picker_page.dart';
import 'package:brickapp/providers/p_filter_provider.dart';
import 'package:brickapp/providers/property_providers.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilterSearch extends ConsumerStatefulWidget {
  const FilterSearch({super.key});

  @override
  ConsumerState<FilterSearch> createState() => _FilterSearchState();
}

class _FilterSearchState extends ConsumerState<FilterSearch> {
  final TextEditingController fromPriceController = TextEditingController();
  final TextEditingController toPriceController = TextEditingController();

  LatLng? pickedLocation;
  String locationDisplay = '';
  double _radiusKm = 10.0; // Changed default to 10km
  String _locationDetail = '';

  final List<String> propertyTypes = [
    "House",
    "Apartments",
    "Business Shop",
    "Venue",
    "Warehouse",
    "Office Space",
    "Land",
    "Farm House",
  ];

  List<String> selectedPropertyTypes = [];

  final Map<String, IconData> amenitiesIcons = {
    "Furnished": Icons.chair,
    "Air Conditioning": Icons.ac_unit,
    "Parking": Icons.local_parking,
    "Security": Icons.security,
    "Internet": Icons.wifi,
    "Pet Friendly": Icons.pets,
    "Compound": Icons.grass,
  };

  Map<String, bool> amenities = {
    "Furnished": false,
    "Air Conditioning": false,
    "Parking": false,
    "Security": false,
    "Internet": false,
    "Pet Friendly": false,
    "Compound": false,
  };

  // New filters
  int _selectedBedrooms = 0;
  int _selectedBathrooms = 0;
  String _sortBy = 'Relevance';
  bool _isForRent = true;
  bool _isForSale = true;

  final List<String> _sortOptions = [
    'Relevance',
    'Price: Low to High',
    'Price: High to Low',
    'Newest First',
    'Oldest First',
  ];

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _hasActiveFilters();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Filter Properties',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (hasActiveFilters)
            TextButton(
              onPressed: _resetFilters,
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                "Reset All",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ─── Quick Filters Chip Bar ─────────────────
                if (hasActiveFilters)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Filters',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (selectedPropertyTypes.isNotEmpty)
                              _buildActiveFilterChip(
                                '${selectedPropertyTypes.length} types',
                                () => setState(() => selectedPropertyTypes.clear()),
                              ),
                            if (_selectedBedrooms > 0)
                              _buildActiveFilterChip(
                                '$_selectedBedrooms bed${_selectedBedrooms > 1 ? 's' : ''}',
                                () => setState(() => _selectedBedrooms = 0),
                              ),
                            if (_selectedBathrooms > 0)
                              _buildActiveFilterChip(
                                '$_selectedBathrooms bath${_selectedBathrooms > 1 ? 's' : ''}',
                                () => setState(() => _selectedBathrooms = 0),
                              ),
                            if (pickedLocation != null)
                              _buildActiveFilterChip(
                                '📍 Within ${_radiusKm.toInt()}km',
                                () => setState(() {
                                  pickedLocation = null;
                                  locationDisplay = '';
                                }),
                              ),
                            if (!_isForRent || !_isForSale)
                              _buildActiveFilterChip(
                                _getListingTypeLabel(),
                                _resetListingTypes,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // ─── Listing Type Toggle ───────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Listing Type",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildListingTypeCard(
                              icon: Icons.home_work,
                              label: 'For Rent',
                              isSelected: _isForRent,
                              onTap: () => setState(() => _isForRent = !_isForRent),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildListingTypeCard(
                              icon: Icons.attach_money,
                              label: 'For Sale',
                              isSelected: _isForSale,
                              onTap: () => setState(() => _isForSale = !_isForSale),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ─── Location Section ──────────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Location",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          if (pickedLocation != null)
                            TextButton(
                              onPressed: () => setState(() {
                                pickedLocation = null;
                                locationDisplay = '';
                              }),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                              ),
                              child: const Text(
                                'Clear',
                                style: TextStyle(color: Colors.orange, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select location to find properties nearby',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _openMapPicker,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: pickedLocation != null
                                ? Colors.orange.shade50
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: pickedLocation != null
                                  ? Colors.orange
                                  : Colors.grey.shade200,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: pickedLocation != null
                                      ? Colors.orange.shade100
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  pickedLocation != null
                                      ? Icons.location_on
                                      : Icons.map_outlined,
                                  color: pickedLocation != null
                                      ? Colors.orange
                                      : Colors.grey.shade600,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pickedLocation != null
                                          ? 'Selected Location'
                                          : 'Tap to select location',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: pickedLocation != null
                                            ? Colors.orange
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      locationDisplay.isEmpty
                                          ? 'Drop a pin on the map'
                                          : locationDisplay,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: locationDisplay.isEmpty
                                            ? Colors.grey.shade400
                                            : Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Radius Slider ─────────────────────────
                if (pickedLocation != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Search Radius',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_radiusKm.toStringAsFixed(0)} km',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _radiusKm,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          activeColor: Colors.blue,
                          inactiveColor: Colors.blue.shade100,
                          label: '${_radiusKm.toStringAsFixed(0)} km',
                          onChanged: (v) => setState(() => _radiusKm = v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1 km', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                            Text('25 km', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                            Text('50 km', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // ─── Property Type Section ─────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Property Type",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: propertyTypes.map((type) {
                          final isSelected = selectedPropertyTypes.contains(type);
                          return FilterChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedPropertyTypes.add(type);
                                } else {
                                  selectedPropertyTypes.remove(type);
                                }
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Colors.orange,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isSelected ? Colors.orange : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // ─── Bedrooms & Bathrooms ──────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildCounterCard(
                          icon: Icons.bed,
                          label: 'Bedrooms',
                          value: _selectedBedrooms,
                          onIncrement: () => setState(() {
                            if (_selectedBedrooms < 10) _selectedBedrooms++;
                          }),
                          onDecrement: () => setState(() {
                            if (_selectedBedrooms > 0) _selectedBedrooms--;
                          }),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCounterCard(
                          icon: Icons.bathtub,
                          label: 'Bathrooms',
                          value: _selectedBathrooms,
                          onIncrement: () => setState(() {
                            if (_selectedBathrooms < 10) _selectedBathrooms++;
                          }),
                          onDecrement: () => setState(() {
                            if (_selectedBathrooms > 0) _selectedBathrooms--;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Price Range ───────────────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Price Range (UGX)",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPriceField(
                              controller: fromPriceController,
                              label: 'Min',
                              hint: '0',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPriceField(
                              controller: toPriceController,
                              label: 'Max',
                              hint: 'Any',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ─── Amenities Grid ────────────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Amenities",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 3,
                        children: amenities.keys.map((amenity) {
                          return _buildAmenityTile(
                            amenity: amenity,
                            icon: amenitiesIcons[amenity]!,
                            isSelected: amenities[amenity]!,
                            onTap: () => setState(() {
                              amenities[amenity] = !amenities[amenity]!;
                            }),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // ─── Sort By Section ───────────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sort By",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: Colors.orange),
                            items: _sortOptions.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _sortBy = value!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Bottom Search Button ───────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Search Properties',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingTypeCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.orange : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard({
    required IconData icon,
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orange.shade700, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCounterButton(Icons.remove, onDecrement),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  value.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
              _buildCounterButton(Icons.add, onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: 'UGX ',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityTile({
    required String amenity,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.grey.shade600,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                amenity,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isSelected ? Colors.orange.shade700 : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.orange, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: Colors.orange.shade50,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.orange.shade700),
      shape: StadiumBorder(side: BorderSide(color: Colors.orange.shade200)),
      padding: const EdgeInsets.only(left: 12, right: 4),
    );
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPicker(
          onLocationSelected: (lat, lng, address) {
            setState(() {
              pickedLocation = LatLng(lat, lng);
              locationDisplay = address;
            });
          },
        ),
      ),
    );
  }

  String _getListingTypeLabel() {
    if (!_isForRent && _isForSale) return 'For Sale Only';
    if (_isForRent && !_isForSale) return 'For Rent Only';
    return '';
  }

  void _resetListingTypes() {
    setState(() {
      _isForRent = true;
      _isForSale = true;
    });
  }

  bool _hasActiveFilters() {
    return selectedPropertyTypes.isNotEmpty ||
        _selectedBedrooms > 0 ||
        _selectedBathrooms > 0 ||
        pickedLocation != null ||
        !_isForRent ||
        !_isForSale ||
        fromPriceController.text.isNotEmpty ||
        toPriceController.text.isNotEmpty ||
        amenities.values.any((v) => v);
  }

  void _applyFilters() {
    final selectedAmenities = amenities.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final filter = PropertyFilter(
      minPrice: double.tryParse(fromPriceController.text.replaceAll(RegExp(r'[^\d]'), '')),
      maxPrice: double.tryParse(toPriceController.text.replaceAll(RegExp(r'[^\d]'), '')),
      latitude: pickedLocation?.latitude,
      longitude: pickedLocation?.longitude,
      radiusKm: pickedLocation != null ? _radiusKm : null,
      propertyTypes: selectedPropertyTypes.isNotEmpty ? selectedPropertyTypes : null,
      amenities: selectedAmenities.isNotEmpty ? selectedAmenities : null,
      bedrooms: _selectedBedrooms > 0 ? _selectedBedrooms : null,
      // bathrooms: _selectedBathrooms > 0 ? _selectedBathrooms : null,
      // isForRent: _isForRent,
      // isForSale: _isForSale,
      // sortBy: _sortBy,
    );

    ref.read(propertyFilterProvider.notifier).state = filter;
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      selectedPropertyTypes.clear();
      amenities.updateAll((key, value) => false);
      fromPriceController.clear();
      toPriceController.clear();
      pickedLocation = null;
      locationDisplay = '';
      _radiusKm = 10.0;
      _selectedBedrooms = 0;
      _selectedBathrooms = 0;
      _sortBy = 'Relevance';
      _isForRent = true;
      _isForSale = true;
    });
  }

  @override
  void dispose() {
    fromPriceController.dispose();
    toPriceController.dispose();
    super.dispose();
  }
}