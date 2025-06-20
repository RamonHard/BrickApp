import 'package:brickapp/custom_widgets/truck_driver_widget.dart';
import 'package:brickapp/models/truck_driver_model.dart';
import 'package:brickapp/providers/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AvailableTrucksScreen extends ConsumerWidget {
  const AvailableTrucksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);

    // Example drivers using booking data
    final availableDrivers = [
      TruckDriver(
        id: '1',
        name: 'John Smith',
        truckType: booking.selectedTruckType ?? 'Medium Truck',
        truckNumber: 'TRK-1234',
        rating: 4.8,
        distance: 1.2,
        price: booking.estimatedPrice ?? 120.0,
        eta: 8,
        imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      ),
      TruckDriver(
        id: '2',
        name: 'Robert Johnson',
        truckType: booking.selectedTruckType ?? 'Medium Truck',
        truckNumber: 'TRK-5678',
        rating: 4.5,
        distance: 2.5,
        price: (booking.estimatedPrice ?? 120.0) + 15.0,
        eta: 15,
        imageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
      ),
      TruckDriver(
        id: '3',
        name: 'Michael Brown',
        truckType: booking.selectedTruckType ?? 'Medium Truck',
        truckNumber: 'TRK-9012',
        rating: 4.9,
        distance: 0.8,
        price: (booking.estimatedPrice ?? 120.0) - 10.0,
        eta: 5,
        imageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Available Trucks'), centerTitle: true),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking.pickupLocation} → ${booking.dropoffLocation}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Truck Type: ${booking.selectedTruckType ?? '-'}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estimated Price: \$${booking.estimatedPrice?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: availableDrivers.length,
              itemBuilder: (context, index) {
                return TruckDriverCard(driver: availableDrivers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
