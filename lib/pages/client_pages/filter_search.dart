import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterSearch extends StatefulWidget {
  @override
  State<FilterSearch> createState() => _FilterSearchState();
}

class _FilterSearchState extends State<FilterSearch> {
  final TextEditingController fromPriceController = TextEditingController(
    text: 'UGX 1000',
  );
  final TextEditingController toPriceController = TextEditingController(
    text: 'UGX 2000',
  );

  List<String> descriptions = [
    "Self Contained",
    "Business Shop",
    "Flat Apartments",
    "Events",
    "Hostels",
    "Offices",
    "Lounges",
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
                  // Trigger search logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Search", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
