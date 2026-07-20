import 'dart:convert';
import 'package:brickapp/models/booking_model.dart';
import 'package:brickapp/providers/booking_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/rating_dialogue.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ClientHistoryPage extends ConsumerWidget {
  const ClientHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(userProvider).token ?? '';
    final propertyBookings = ref.watch(myPropertyBookingsProvider(token));

    return DefaultTabController(
      length: 1,
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
            ],
          ),
        ),
        body: TabBarView(
          children: [
            propertyBookings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => _buildError(
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
                  itemBuilder: (_, i) => _PropertyBookingCard(
                    booking: bookings[i],
                    onVisitConfirmed: () =>
                        ref.refresh(myPropertyBookingsProvider(token)),
                  ),
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
          Text(message,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Property Booking Card ────────────────────────────────
class _PropertyBookingCard extends ConsumerStatefulWidget {
  final PropertyBookingModel booking;
  final VoidCallback onVisitConfirmed;

  const _PropertyBookingCard({
    required this.booking,
    required this.onVisitConfirmed,
  });

  @override
  ConsumerState<_PropertyBookingCard> createState() =>
      _PropertyBookingCardState();
}

class _PropertyBookingCardState extends ConsumerState<_PropertyBookingCard> {
  bool _isConfirming = false;
  bool _isRating = false;

  Color get _statusColor {
    switch (widget.booking.status) {
      case 'awaiting_visit':
        return Colors.blue;
      case 'visit_confirmed':
        return Colors.green;
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

  String get _statusLabel {
    switch (widget.booking.status) {
      case 'awaiting_visit':
        return 'AWAITING VISIT';
      case 'visit_confirmed':
        return 'VISIT CONFIRMED';
      default:
        return widget.booking.status.replaceAll('_', ' ').toUpperCase();
    }
  }

  Future<void> _confirmVisit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Property Visit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('By confirming, you acknowledge that:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _confirmPoint('✅ You have physically visited the property'),
            _confirmPoint('✅ The property matches the listing description'),
            _confirmPoint('✅ You are satisfied and ready to move in'),
            _confirmPoint(
                '✅ Payment will be permanently released to the manager'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Text(
                '⚠️ This action cannot be undone. Only confirm if you have visited the property.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Yes, Confirm Visit',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isConfirming = true);

    try {
      final token = ref.read(userProvider).token ?? '';
      final res = await http.patch(
        Uri.parse(AppUrls.confirmPropertyVisit(widget.booking.id)),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '✅ Visit confirmed! Payment released to manager.'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onVisitConfirmed();
      } else {
        final data = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(data['message'] ?? 'Failed to confirm visit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) setState(() => _isConfirming = false);
  }

  Widget _confirmPoint(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: const TextStyle(fontSize: 13)),
      );

  // ✅ NEW: Show Rating Dialog
  Future<void> _showRatingDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        bookingId: widget.booking.id,
        propertyName: widget.booking.propertyType ?? 'Property',
      ),
    );

    if (result == true && mounted) {
      // Refresh the page to update the UI
      widget.onVisitConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final dateFormat = DateFormat('dd MMM yyyy');
    final booking = widget.booking;

    final allMedia = [
      if (booking.videoUrl != null) booking.videoUrl!,
      ...booking.insideViewUrls,
    ];

    // ✅ Check if 30 days have passed since booking
    final daysSinceBooking = DateTime.now().difference(booking.createdAt).inDays;
    final canRate = booking.status == 'visit_confirmed' && 
                    daysSinceBooking >= 30 && 
                    booking.rating == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Thumbnail + status ─────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)),
                child: booking.thumbnailUrl != null
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
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
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
                Text(booking.propertyType ?? 'Property',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.address ?? '',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Amenities
                if (booking.bedrooms != null ||
                    booking.bathrooms != null ||
                    booking.squareFeet != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (booking.bedrooms != null)
                        _amenityChip(
                            Icons.bed, '${booking.bedrooms} Beds'),
                      if (booking.bathrooms != null)
                        _amenityChip(Icons.bathroom,
                            '${booking.bathrooms} Baths'),
                      if (booking.squareFeet != null)
                        _amenityChip(Icons.square_foot,
                            '${booking.squareFeet!.toInt()} sqft'),
                    ],
                  ),
                ],

                // Media gallery
                if (allMedia.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Featured Media',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: allMedia.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final url = allMedia[i];
                        final isVideo = url.endsWith('.mp4') ||
                            url.endsWith('.mov');
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              Image.network(
                                isVideo
                                    ? (booking.thumbnailUrl ?? url)
                                    : url,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
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
                                    child: Icon(Icons.play_circle_fill,
                                        color: Colors.white, size: 28),
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

                // Owner info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.orange[100],
                      backgroundImage: booking.ownerAvatar != null &&
                              booking.ownerAvatar!.isNotEmpty
                          ? NetworkImage(
                              '${AppUrls.baseUrl}/${booking.ownerAvatar}')
                          : null,
                      child: booking.ownerAvatar == null ||
                              booking.ownerAvatar!.isEmpty
                          ? Text(
                              (booking.ownerName ?? 'M')[0].toUpperCase(),
                              style: TextStyle(
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.bold),
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
                                fontSize: 13),
                          ),
                          Text(
                            booking.ownerPhone ?? '',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
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
                        child: Icon(Icons.phone,
                            color: Colors.green[700], size: 18),
                      ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Dates
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${dateFormat.format(booking.startDate)} → ${dateFormat.format(booking.endDate)}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Paid',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11)),
                        Text(
                          'UGX ${formatter.format(booking.totalPrice)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Platform fee',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11)),
                        Text(
                          'UGX ${formatter.format(booking.platformCommission)}',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),

                // ─── ESCROW / VISIT CONFIRMATION ─────────
                if (booking.status == 'awaiting_visit') ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.home_work,
                                color: Colors.blue, size: 18),
                            SizedBox(width: 8),
                            Text('Next Step',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Visit the property physically. Once you are satisfied, tap "Confirm Visit" to release the payment to the manager.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.blue),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock,
                                  color: Colors.orange[700], size: 14),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'Your payment is safely locked in escrow until you confirm.',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isConfirming ? null : _confirmVisit,
                            icon: _isConfirming
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2))
                                : const Icon(Icons.check_circle,
                                    color: Colors.white, size: 18),
                            label: Text(
                              _isConfirming
                                  ? 'Confirming...'
                                  : 'Confirm Property Visit',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (booking.status == 'visit_confirmed') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified,
                            color: Colors.green, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Visit Confirmed!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                              SizedBox(height: 2),
                              Text(
                                'Payment has been released to the property manager.',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ✅ RATING SECTION - Show after 30 days
                if (canRate) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rate_rounded,
                            color: Colors.amber, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rate Your Experience ⭐',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Share your experience with this property',
                                style: TextStyle(
                                  color: Colors.amber[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _showRatingDialog,
                          icon: const Icon(Icons.star_border, size: 16),
                          label: const Text('Rate Now'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber[800],
                            side: BorderSide(color: Colors.amber[200]!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ✅ Already Rated - Show rating badge
                if (booking.rating != null && booking.rating! > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < (booking.rating ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${booking.rating ?? 0}.0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Rated',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: Colors.grey[700])),
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