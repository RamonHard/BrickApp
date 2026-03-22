import 'package:brickapp/models/booking_model.dart';
import 'package:brickapp/providers/booking_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ClientHistoryPage extends ConsumerWidget {
  const ClientHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(userProvider).token ?? '';

    final propertyBookings = ref.watch(myPropertyBookingsProvider(token));
    final transportBookings = ref.watch(myTransportBookingsProvider(token));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.whiteBG,
        appBar: AppBar(
          title: Text(
            'My Bookings',
            style: GoogleFonts.actor(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            tabs: [Tab(text: 'Properties'), Tab(text: 'Transport')],
          ),
        ),
        body: TabBarView(
          children: [
            // Property bookings tab
            propertyBookings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load bookings'),
                        TextButton(
                          onPressed:
                              () => ref.refresh(
                                myPropertyBookingsProvider(token),
                              ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
              data: (bookings) {
                if (bookings.isEmpty) {
                  return const Center(child: Text('No property bookings yet'));
                }
                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookings[index];
                    return _PropertyBookingCard(booking: b);
                  },
                );
              },
            ),

            // Transport bookings tab
            transportBookings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load transport bookings'),
                        TextButton(
                          onPressed:
                              () => ref.refresh(
                                myTransportBookingsProvider(token),
                              ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
              data: (bookings) {
                if (bookings.isEmpty) {
                  return const Center(child: Text('No transport bookings yet'));
                }
                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookings[index];
                    return _TransportBookingCard(booking: b);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyBookingCard extends StatelessWidget {
  final PropertyBookingModel booking;
  const _PropertyBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading:
            booking.thumbnailUrl != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    booking.thumbnailUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => const Icon(Icons.home, size: 40),
                  ),
                )
                : const Icon(Icons.home, size: 40),
        title: Text(
          booking.propertyType ?? 'Property',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.address ?? 'Address not set'),
            Text(
              '${DateFormat('dd MMM yyyy').format(booking.startDate)} → '
              '${DateFormat('dd MMM yyyy').format(booking.endDate)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'UGX ${formatter.format(booking.totalPrice)}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                booking.status == 'confirmed'
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            booking.status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color:
                  booking.status == 'confirmed' ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransportBookingCard extends StatelessWidget {
  final TransportBookingModel booking;
  const _TransportBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.local_shipping, color: Colors.white),
        ),
        title: Text(
          booking.vehicleTypeName ?? 'Truck',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${booking.pickupLocation} → ${booking.dropoffLocation}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('${booking.distanceKm} km'),
            Text(
              'UGX ${formatter.format(booking.totalPrice)}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                booking.status == 'confirmed'
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            booking.status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color:
                  booking.status == 'confirmed' ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
