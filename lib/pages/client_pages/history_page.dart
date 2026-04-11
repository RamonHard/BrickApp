import 'package:brickapp/models/booking_model.dart';
import 'package:brickapp/models/transport_booking_model.dart';
import 'package:brickapp/providers/booking_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
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
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(),
          title: Text(
            'My Bookings',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.iconColor,
            labelColor: AppColors.iconColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.home), text: 'Properties'),
              Tab(icon: Icon(Icons.local_shipping), text: 'Transport'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ─── Property Bookings Tab ──────────────────
            propertyBookings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, _) => _buildError(
                    'Failed to load property bookings',
                    () => ref.refresh(myPropertyBookingsProvider(token)),
                  ),
              data: (bookings) {
                if (bookings.isEmpty) {
                  return _buildEmpty(
                    icon: Icons.home_outlined,
                    message: 'No property bookings yet',
                    subtitle: 'Your property bookings will appear here',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: bookings.length,
                  itemBuilder:
                      (_, i) => _PropertyBookingCard(booking: bookings[i]),
                );
              },
            ),

            // ─── Transport Bookings Tab ─────────────────
            transportBookings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, _) => _buildError(
                    'Failed to load transport bookings',
                    () => ref.refresh(myTransportBookingsProvider(token)),
                  ),
              data: (bookings) {
                if (bookings.isEmpty) {
                  return _buildEmpty(
                    icon: Icons.local_shipping_outlined,
                    message: 'No transport bookings yet',
                    subtitle: 'Your truck and bus bookings will appear here',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: bookings.length,
                  itemBuilder:
                      (_, i) => _TransportBookingCard(booking: bookings[i]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmpty({
    required IconData icon,
    required String message,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Property Booking Card ────────────────────────────────
class _PropertyBookingCard extends StatelessWidget {
  final PropertyBookingModel booking;
  const _PropertyBookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case 'confirmed':
        return Colors.green;
      case 'refund_requested':
        return Colors.purple;
      case 'refund_approved':
        return Colors.blue;
      case 'refunded':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final dateFormat = DateFormat('dd MMM yyyy');
    final allMedia = [
      if (booking.videoUrl != null) booking.videoUrl!,
      ...booking.insideViewUrls,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Thumbnail + status ─────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child:
                    booking.thumbnailUrl != null
                        ? Image.network(
                          booking.thumbnailUrl!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                        : _buildPlaceholder(),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property type + address
                Text(
                  booking.propertyType ?? 'Property',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.address ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Amenities row
                if (booking.bedrooms != null ||
                    booking.bathrooms != null ||
                    booking.squareFeet != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (booking.bedrooms != null)
                        _amenityChip(Icons.bed, '${booking.bedrooms} Beds'),
                      if (booking.bathrooms != null)
                        _amenityChip(
                          Icons.bathroom,
                          '${booking.bathrooms} Baths',
                        ),
                      if (booking.squareFeet != null)
                        _amenityChip(
                          Icons.square_foot,
                          '${booking.squareFeet!.toInt()} sqft',
                        ),
                    ],
                  ),
                ],

                // ✅ Featured Media Gallery
                if (allMedia.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Featured Media',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: allMedia.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final url = allMedia[i];
                        final isVideo =
                            url.endsWith('.mp4') || url.endsWith('.mov');
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              Image.network(
                                isVideo ? (booking.thumbnailUrl ?? url) : url,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        isVideo
                                            ? Icons.play_circle
                                            : Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                              if (isVideo)
                                const Positioned.fill(
                                  child: Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Property manager info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.orange[100],
                      backgroundImage:
                          booking.ownerAvatar != null &&
                                  booking.ownerAvatar!.isNotEmpty
                              ? NetworkImage(
                                '${AppUrls.baseUrl}/${booking.ownerAvatar}',
                              )
                              : null,
                      child:
                          booking.ownerAvatar == null ||
                                  booking.ownerAvatar!.isEmpty
                              ? Text(
                                (booking.ownerName ?? 'M')[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                              : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.ownerName ?? 'Property Manager',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            booking.ownerPhone ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (booking.ownerPhone != null)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Icon(
                          Icons.phone,
                          color: Colors.green[700],
                          size: 18,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Dates + amount
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${dateFormat.format(booking.startDate)} → ${dateFormat.format(booking.endDate)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Paid',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'UGX ${formatter.format(booking.totalPrice)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Platform fee',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'UGX ${formatter.format(booking.platformCommission)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amenityChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 160,
      color: Colors.grey[200],
      child: Icon(Icons.home, size: 48, color: Colors.grey[400]),
    );
  }
}

// ─── Transport Booking Card ───────────────────────────────
class _TransportBookingCard extends StatelessWidget {
  final TransportBookingModel booking;
  const _TransportBookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case 'paid':
        return Colors.green;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.teal;
      case 'declined':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'requested':
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }

  IconData get _vehicleIcon {
    switch (booking.vehicleTypeName) {
      case 'Bus':
        return Icons.directions_bus;
      case 'Costa':
        return Icons.directions_bus_filled;
      case 'Trailer':
        return Icons.rv_hookup;
      case 'Large Truck':
        return Icons.airport_shuttle;
      default:
        return Icons.local_shipping;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: vehicle type + status ─────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_vehicleIcon, color: Colors.blue[700], size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.vehicleTypeName ?? 'Transport',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (booking.brand != null || booking.plateNumber != null)
                        Text(
                          '${booking.brand ?? ''} • ${booking.plateNumber ?? ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    booking.status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ─── Route ─────────────────────────────────
            Row(
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.my_location,
                      color: Colors.green,
                      size: 16,
                    ),
                    Container(width: 1, height: 20, color: Colors.grey[300]),
                    const Icon(Icons.location_on, color: Colors.red, size: 16),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.pickupLocation,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        booking.dropoffLocation,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${booking.distanceKm.toStringAsFixed(0)} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'UGX ${formatter.format(booking.pricePerKm)}/km',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ─── ✅ Service Provider info ───────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    (booking.providerName ?? 'D')[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.providerName ?? 'Service Provider',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        booking.providerPhone ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (booking.providerPhone != null)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Icon(
                      Icons.phone,
                      color: Colors.green[700],
                      size: 18,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ─── Amount + date ─────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                    Text(
                      'UGX ${formatter.format(booking.totalPrice)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateFormat.format(booking.bookingDate),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
