import 'package:brickapp/custom_widgets/date_time_picker_widget.dart';
import 'package:brickapp/custom_widgets/location_input.dart';
import 'package:brickapp/custom_widgets/truck_type_select_widget.dart';
import 'package:brickapp/pages/client_pages/client_book_tuck_Services/available_turck.dart';
import 'package:brickapp/providers/booking_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FindTransporterPage extends ConsumerWidget {
  const FindTransporterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Book a Truck',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black),
      ),
      body: Column(
        children: [
          // Map Placeholder (like Uber)
          Container(
            height: 200,
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 50, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(
                    'Map View',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // Booking Card (like Uber's ride selection)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location Inputs with Uber-style design
                    _buildLocationInputs(bookingNotifier),
                    const SizedBox(height: 24),

                    // Truck Type Selector
                    _buildTruckTypeSection(),
                    const SizedBox(height: 24),

                    // Date and Time Picker
                    _buildDateTimeSection(),
                    const SizedBox(height: 32),

                    // Book Truck Button
                    _buildBookButton(context, booking, bookingNotifier),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInputs(BookingNotifier bookingNotifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        children: [
          // Pickup Location
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LocationInput(
                    onLocationSelected: (location) {
                      bookingNotifier.setPickupLocation(location);
                    },
                    hintText: 'Enter pickup location',
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ],
            ),
          ),

          // Dropoff Location
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LocationInput(
                    onLocationSelected: (location) {
                      bookingNotifier.setDropoffLocation(location);
                    },
                    hintText: 'Enter dropoff location',
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTruckTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT TRUCK TYPE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: const TruckTypeSelector(),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SCHEDULE PICKUP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        const DateTimePicker(),
      ],
    );
  }

  Widget _buildBookButton(
    BuildContext context,
    BookingState booking,
    BookingNotifier bookingNotifier,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
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
            const SnackBar(
              content: Text('Please fill all fields'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: const Text(
        'FIND AVAILABLE TRUCKS',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
