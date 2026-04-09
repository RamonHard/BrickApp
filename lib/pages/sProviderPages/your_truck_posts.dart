// pages/my_trucks_list_page.dart
import 'dart:convert';
import 'package:brickapp/models/truck_driver_model.dart';
import 'package:brickapp/pages/sProviderPages/edit_posted_truck.dart';
import 'package:brickapp/pages/sProviderPages/post_truck.dart';
import 'package:brickapp/providers/truck_driver_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MyTrucksListPage extends ConsumerStatefulWidget {
  const MyTrucksListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyTrucksListPage> createState() => _MyTrucksListPageState();
}

class _MyTrucksListPageState extends ConsumerState<MyTrucksListPage> {
  List<Truck> _myTrucks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMyTrucks();
  }

  Future<void> _fetchMyTrucks() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = ref.read(userProvider).token;

      if (token == null) {
        throw Exception('You must be logged in');
      }

      final response = await http.get(
        Uri.parse('${AppUrls.baseUrl}/vehicles/my'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> vehicles = data['vehicles'];

        final List<Truck> trucks =
            vehicles.map((v) {
              // Handle price_per_km - could be null, string, or number
              double pricePerKm = 0;
              if (v['price_per_km'] != null) {
                pricePerKm = double.tryParse(v['price_per_km'].toString()) ?? 0;
              } else if (v['price'] != null) {
                pricePerKm = double.tryParse(v['price'].toString()) ?? 0;
              }

              // Handle capacity
              String capacity = '0';
              if (v['capacity'] != null &&
                  v['capacity'].toString().isNotEmpty) {
                capacity = v['capacity'].toString();
              }

              // Handle photo URL
              String? photoUrl = v['photo_url'];

              return Truck(
                id: v['id'].toString(),
                truckModel: v['brand'] ?? '',
                licensePlate: v['plate_number'] ?? '',
                vehicleType: v['vehicle_type_name'] ?? '',
                capacity: capacity,
                pricePerKm: pricePerKm,
                phone: v['phone'] ?? '',
                email: v['email'] ?? '',
                photo: null, // We'll handle photo URL separately
                photoUrl: photoUrl, // Add this to your Truck model
                createdAt: DateTime.parse(v['created_at']),
                ownerId: v['user_id'].toString(),
                isAvailable: v['is_available'] ?? false,
              );
            }).toList();

        setState(() {
          _myTrucks = trucks;
          _isLoading = false;
        });

        // Update provider
        ref.read(truckProvider.notifier).setTrucks(trucks);
      } else {
        throw Exception('Failed to load trucks');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error fetching trucks: $e');
    }
  }

  Future<void> _toggleAvailability(Truck truck) async {
    try {
      final token = ref.read(userProvider).token;

      final response = await http.patch(
        Uri.parse('${AppUrls.baseUrl}/vehicles/${truck.id}/availability'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedTruck = data['vehicle'];

        // Update local list
        setState(() {
          final index = _myTrucks.indexWhere((t) => t.id == truck.id);
          if (index != -1) {
            _myTrucks[index] = Truck(
              id: updatedTruck['id'].toString(),
              truckModel: updatedTruck['brand'] ?? '',
              licensePlate: updatedTruck['plate_number'] ?? '',
              vehicleType: truck.vehicleType,
              capacity: updatedTruck['capacity']?.toString() ?? '0',
              pricePerKm: (updatedTruck['price_per_km'] ?? 0).toDouble(),
              phone: updatedTruck['phone'] ?? '',
              email: updatedTruck['email'] ?? '',
              photo: null,
              createdAt: DateTime.now(),
              ownerId: updatedTruck['user_id'].toString(),
              isAvailable: updatedTruck['is_available'] ?? false,
            );
          }
        });

        // Update provider
        ref.read(truckProvider.notifier).toggleAvailability(truck.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _myTrucks.firstWhere((t) => t.id == truck.id).isAvailable
                  ? 'Truck is now available'
                  : 'Truck is now unavailable',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error toggling availability: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update availability'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTruck(String truckId) async {
    try {
      final token = ref.read(userProvider).token;

      // Note: You'll need to add a DELETE endpoint in your backend
      final response = await http.delete(
        Uri.parse('${AppUrls.baseUrl}/vehicles/$truckId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _myTrucks.removeWhere((t) => t.id == truckId);
        });
        ref.read(truckProvider.notifier).removeTruck(truckId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Truck deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting truck: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete truck'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostTruckPage()),
              ).then((_) => _fetchMyTrucks()); // Refresh on return
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMyTrucks,
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
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.iconColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMyTrucks,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.iconColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_myTrucks.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMyTrucksList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Trucks Posted',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Post your first truck to get started',
            style: GoogleFonts.poppins(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostTruckPage()),
              ).then((_) => _fetchMyTrucks());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.iconColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildMyTrucksList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myTrucks.length,
      itemBuilder: (context, index) {
        final truck = _myTrucks[index];
        return _buildMyTruckCard(truck);
      },
    );
  }

  Widget _buildMyTruckCard(Truck truck) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
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
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    color: AppColors.iconColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 4),
                      Text(
                        truck.vehicleType,
                        style: GoogleFonts.poppins(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoItem(Icons.confirmation_number, truck.licensePlate),
                const SizedBox(width: 16),
                _buildInfoItem(Icons.scale, '${truck.capacity} Tons'),
                const SizedBox(width: 16),
                _buildInfoItem(
                  Icons.attach_money,
                  'UGX ${truck.pricePerKm.toStringAsFixed(0)}/Km',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTruckPage(truck: truck),
                        ),
                      ).then((_) => _fetchMyTrucks()); // Refresh on return
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      truck.isAvailable ? Icons.block : Icons.check_circle,
                      size: 16,
                    ),
                    label: Text(
                      truck.isAvailable ? 'Make Unavailable' : 'Make Available',
                    ),
                    onPressed: () => _toggleAvailability(truck),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          truck.isAvailable ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade400),
                  onPressed: () {
                    _showDeleteDialog(truck.id);
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
          const SizedBox(width: 4),
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

  void _showDeleteDialog(String truckId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Truck'),
            content: Text('Are you sure you want to delete this truck?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteTruck(truckId);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
