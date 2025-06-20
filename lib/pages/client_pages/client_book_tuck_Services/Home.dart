import 'package:brickapp/custom_widgets/date_time_picker_widget.dart';
import 'package:brickapp/custom_widgets/location_input.dart';
import 'package:brickapp/custom_widgets/truck_type_select_widget.dart';
import 'package:brickapp/pages/client_pages/client_book_tuck_Services/available_turck.dart';
import 'package:brickapp/providers/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FindTransporterPage extends ConsumerWidget {
  const FindTransporterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Book a Truck'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pickup Location
            const Text(
              'Pickup Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LocationInput(
              onLocationSelected: (location) {
                bookingNotifier.setPickupLocation(location);
              },
              hintText: 'Enter pickup location',
            ),
            const SizedBox(height: 20),

            // Dropoff Location
            const Text(
              'Dropoff Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LocationInput(
              onLocationSelected: (location) {
                bookingNotifier.setDropoffLocation(location);
              },
              hintText: 'Enter dropoff location',
            ),
            const SizedBox(height: 20),

            // Truck Type Selector
            const Text(
              'Select Truck Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TruckTypeSelector(),
            const SizedBox(height: 20),

            // Date and Time Picker
            const Text(
              'When do you need the truck?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const DateTimePicker(),
            const SizedBox(height: 30),

            // Book Truck Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (booking.pickupLocation != null &&
                    booking.dropoffLocation != null &&
                    booking.selectedTruckType != null) {
                  // In a real app, calculate distance dynamically
                  bookingNotifier.calculatePrice(15.0); // Example: 15km

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AvailableTrucksScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text(
                'Find Available Trucks',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
