import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/client_pages/filter_search.dart';
import 'package:brickapp/providers/property_providers.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../custom_widgets/house_card.dart';
import '../../utils/app_colors.dart';

class HomePage extends ConsumerWidget {
  HomePage({Key? key}) : super(key: key);

  final TextStyle style = GoogleFonts.actor(
    fontSize: 18,
    color: Colors.black,
    fontWeight: FontWeight.w800,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertiesProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(child: Text("Brick App", style: style)),
            const SizedBox(height: 10),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search properties...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  // TODO: implement search
                },
              ),
            ),
            const SizedBox(height: 8),

            // Filter button
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: MaterialButton(
                color: AppColors.iconColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FilterSearch()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  "Sort by",
                  style: GoogleFonts.actor(
                    fontSize: 16,
                    color: HexColor('FFFFFF'),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Properties list
            Expanded(
              child: propertiesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 10),
                          Text('Failed to load properties'),
                          TextButton(
                            onPressed: () => ref.refresh(propertiesProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                data: (properties) {
                  if (properties.isEmpty) {
                    return const Center(child: Text('No properties found'));
                  }
                  return ListView.builder(
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: HouseCard(
                          profileIMG: '',
                          price: property.displayPrice,
                          location: property.address ?? 'Location not set',
                          description: property.description ?? '',
                          thumbnail: property.thumbnailUrl ?? '',
                          houseType: property.propertyType,
                          isActive: property.status == 'active',
                          id: property.id,
                          uploaderName: property.ownerName ?? '',
                          unitsNum: property.units ?? 0,
                          bedroomNum: property.bedrooms ?? 0,
                          starRating: 0,
                          reviews: 0,
                          sqft: property.sqft,
                          onTap: () {
                            MainNavigation.navigateToRoute(
                              MainNavigation.viewSelectedProductRoute,
                              data: property,
                            );
                          },
                          showDelete: false,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
