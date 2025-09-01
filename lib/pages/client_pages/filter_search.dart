import 'package:brickapp/pages/client_pages/location_picker_page.dart';
import 'package:brickapp/providers/p_filter_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/property_filter_model.dart' show FilterModel;

class FilterSearch extends ConsumerStatefulWidget {
  @override
  ConsumerState<FilterSearch> createState() => _FilterSearchState();
}

class _FilterSearchState extends ConsumerState<FilterSearch> {
  final TextEditingController fromPriceController = TextEditingController();
  final TextEditingController toPriceController = TextEditingController();
  LatLng? pickedLocation;
  String locationDisplay = '';

  List<String> descriptions = [
    "Self Contained",
    "Business Shop",
    "Flat Apartments",
    "Event Grounds",
    "Hostels",
    "Offices",
    "Lounges",
    "Storage House",
    "Warehouse",
  ];

  List<String> selectedDescriptions = [];

  Map<String, bool> amenities = {
    "Furnished": false,
    "Air Conditioning": false,
    "Parking": false,
    "Security": false,
    "Water Supply": false,
    "Internet": false,
    "Backup Power": false,
    "Pet Friendly": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Filter',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedDescriptions.clear();
                amenities.updateAll((key, value) => false);
                fromPriceController.text = 'UGX 1000';
                toPriceController.text = 'UGX 2000';
              });
            },
            child: Text("Reset", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LocationPickerPage()),
                );

                if (result != null && result is LatLng) {
                  setState(() {
                    pickedLocation = result;
                    locationDisplay =
                        "Lat: ${result.latitude}, Lng: ${result.longitude}";
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(179, 235, 246, 250),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        locationDisplay.isEmpty
                            ? "Select from map"
                            : locationDisplay,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                    ),
                    Icon(Icons.map, color: Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Select Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  descriptions.map((desc) {
                    final isSelected = selectedDescriptions.contains(desc);
                    return ChoiceChip(
                      label: Text(
                        desc,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDescriptions.add(desc);
                          } else {
                            selectedDescriptions.remove(desc);
                          }
                        });
                      },
                      selectedColor: Colors.orange,
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              "Select Price Range",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "From",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 40,
              child: TextField(
                controller: fromPriceController,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextColor,
                ),

                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(179, 235, 246, 250),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "To",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 40,
              child: TextField(
                controller: toPriceController,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextColor,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(179, 235, 246, 250),

                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Amenities",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 4,
              children:
                  amenities.keys.map((amenity) {
                    return CheckboxListTile(
                      title: Text(
                        amenity,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromARGB(255, 129, 129, 129),
                        ),
                      ),
                      value: amenities[amenity],
                      onChanged: (value) {
                        setState(() {
                          amenities[amenity] = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final fromPrice = double.tryParse(
                    fromPriceController.text.replaceAll(RegExp(r'[^\d]'), ''),
                  );
                  final toPrice = double.tryParse(
                    toPriceController.text.replaceAll(RegExp(r'[^\d]'), ''),
                  );

                  ref.read(filterProvider.notifier).state = FilterModel(
                    selectedDescriptions: selectedDescriptions,
                    fromPrice: fromPrice,
                    toPrice: toPrice,
                    selectedAmenities: amenities,
                  );

                  Navigator.pop(context);
                },
                child: Text("Search"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
