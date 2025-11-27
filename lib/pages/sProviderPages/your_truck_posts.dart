// pages/my_trucks_list_page.dart
import 'package:brickapp/models/truck_driver_model.dart';
import 'package:brickapp/pages/sProviderPages/edit_posted_truck.dart';
import 'package:brickapp/pages/sProviderPages/post_truck.dart';
import 'package:brickapp/providers/truck_driver_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTrucksListPage extends ConsumerWidget {
  const MyTrucksListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTrucks = ref.watch(myTrucksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Trucks',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.iconColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostTruckPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.iconColor.withOpacity(0.1),
              Colors.grey.shade100,
            ],
          ),
        ),
        child:
            myTrucks.isEmpty
                ? _buildEmptyState(context)
                : _buildMyTrucksList(myTrucks, ref),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'No Trucks Posted',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Post your first truck to get started',
            style: GoogleFonts.poppins(color: Colors.grey.shade500),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostTruckPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.iconColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Post Your First Truck',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTrucksList(List<Truck> trucks, WidgetRef ref) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: trucks.length,
      itemBuilder: (context, index) {
        final truck = trucks[index];
        return _buildMyTruckCard(context, truck, ref);
      },
    );
  }

  Widget _buildMyTruckCard(BuildContext context, Truck truck, WidgetRef ref) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.iconColor.withOpacity(0.1),
                    image:
                        truck.photo != null
                            ? DecorationImage(
                              image: FileImage(truck.photo!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      truck.photo == null
                          ? Icon(
                            Icons.local_shipping,
                            color: AppColors.iconColor,
                            size: 30,
                          )
                          : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        truck.truckModel,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        truck.vehicleType,
                        style: GoogleFonts.poppins(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        truck.isAvailable
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    truck.isAvailable ? 'Available' : 'Not Available',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: truck.isAvailable ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 8),
            Row(
              children: [
                _buildInfoItem(Icons.confirmation_number, truck.licensePlate),
                SizedBox(width: 16),
                _buildInfoItem(Icons.scale, '${truck.capacity} Tons'),
                SizedBox(width: 16),
                _buildInfoItem(
                  Icons.attach_money,
                  'UGX ${truck.pricePerKm}/Km',
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Edit'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTruckPage(truck: truck),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      truck.isAvailable ? Icons.block : Icons.check_circle,
                      size: 16,
                    ),
                    label: Text(
                      truck.isAvailable ? 'Make Unavailable' : 'Make Available',
                    ),
                    onPressed: () {
                      ref
                          .read(truckProvider.notifier)
                          .toggleAvailability(truck.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          truck.isAvailable ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade400),
                  onPressed: () {
                    _showDeleteDialog(context, truck.id, ref);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String truckId, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Truck'),
            content: Text('Are you sure you want to delete this truck?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(truckProvider.notifier).removeTruck(truckId);
                  Navigator.pop(context);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
