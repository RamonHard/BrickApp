import 'package:brickapp/custom_widgets/search_field.dart';
import 'package:brickapp/custom_widgets/truck_widget.dart';
import 'package:brickapp/pages/client_pages/tuck_detailed.dart';
import 'package:brickapp/providers/search_and_query_provider.dart';
import 'package:brickapp/providers/truck_driver_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../utils/app_colors.dart';

class Transporter extends ConsumerWidget {
  Transporter({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final truckDriverList = ref.watch(truckProviderr);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedTruckType = ref.watch(truckTypeFilterProvider);

    // Filter the truckDriverList based on search and truckType filter
    final filteredList =
        truckDriverList.where((driver) {
          final matchesSearch =
              driver.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              driver.startingPrice.toString().contains(searchQuery);
          final matchesTruckType =
              selectedTruckType == null ||
              driver.truckType == selectedTruckType;
          return matchesSearch && matchesTruckType;
        }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.backgroundColor,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
          ),
          title: Text(
            "Find Truck",
            style: GoogleFonts.oxygen(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textColor,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
                left: 16,
                right: 16,
                top: 8,
              ),
              child: SearchCard(
                hintText: 'Search truck / price',
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
            ),
            _TruckTypeFilter(ref),
            Expanded(
              child:
                  filteredList.isEmpty
                      ? const Center(child: Text("No trucks found."))
                      : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final truckDriverModel = filteredList[index];
                          return SProviderWidget(
                            name: truckDriverModel.name,
                            truckImg: truckDriverModel.truckImg,
                            profileImg: truckDriverModel.profileImg,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DriverProfilePage(
                                        driverModel: truckDriverModel,
                                      ),
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

// Filter by Truck Type (example)
class _TruckTypeFilter extends StatelessWidget {
  final WidgetRef ref;

  _TruckTypeFilter(this.ref);

  @override
  Widget build(BuildContext context) {
    final selectedTruckType = ref.watch(truckTypeFilterProvider);
    final truckTypes = [
      'All',
      'Small',
      'Medium',
      'Large',
    ]; // Example categories

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: truckTypes.length,
        itemBuilder: (context, index) {
          final type = truckTypes[index];
          final isSelected =
              selectedTruckType == type ||
              (type == 'All' && selectedTruckType == null);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (_) {
                ref.read(truckTypeFilterProvider.notifier).state =
                    (type == 'All') ? null : type;
              },
              selectedColor: AppColors.iconColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
