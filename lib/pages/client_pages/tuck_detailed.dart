import 'package:brickapp/models/tuck_driver_model.dart';
import 'package:brickapp/notifiers/fav_cars_service_notifier.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DriverProfilePage extends ConsumerWidget {
  final TruckDriverModel driverModel;

  const DriverProfilePage({super.key, required this.driverModel});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoriteListProvider.select(
        (favorites) => favorites.contains(driverModel),
      ),
    );
    final favoriteListNotifier = ref.read(favoriteListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
        ),
        title: Text(
          "Transportation",
          style: GoogleFonts.oxygen(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (isFavorite) {
                favoriteListNotifier.removeFromFavorites(driverModel);
              } else {
                favoriteListNotifier.addToFavorites(driverModel);
              }
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(driverModel.profileImg),
            ),
            SizedBox(height: 8),
            Text(
              driverModel.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: Colors.blue, size: 16),
                SizedBox(width: 4),
                Text("Verified Driver", style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  driverModel.starRating,
                  (index) => Icon(Icons.star, color: Colors.amber, size: 16),
                ),
                SizedBox(width: 4),
                Text(
                  "${driverModel.starRating} (${driverModel.trips} trips)",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Hero Image (with animation)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            DriverProfilePage(driverModel: driverModel),
                  ),
                );
              },
              child: Card(
                child: Column(
                  children: [
                    Hero(
                      tag:
                          driverModel
                              .truckImg, // Use unique tag (image URL works great)
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          driverModel.truckImg,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(driverModel.name),
                      subtitle: Text(driverModel.location),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),
            // Info Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.orange),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Location",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            driverModel.location,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    children: [
                      Icon(Icons.local_shipping, color: Colors.orange),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Vehicle Type",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "Tesla Semi Truck",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.orange),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Starting Price",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "${driverModel.startingPrice}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Badges
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.verified_user, color: Colors.orange),
                        SizedBox(height: 8),
                        Text(
                          "Fully Insured",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Protected Transport",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.shield, color: Colors.orange),
                        SizedBox(height: 8),
                        Text(
                          "Verified Driver",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Background Checked",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Reach Out Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // handle action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Reach Out", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
