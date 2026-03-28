import 'dart:convert';
import 'package:brickapp/providers/request_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RequestsFromClientToServiceProvider extends ConsumerWidget {
  const RequestsFromClientToServiceProvider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(userProvider).token ?? '';
    final requestsAsync = ref.watch(providerRequestsProvider(token));
    final formatter = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transport Requests',
          style: GoogleFonts.actor(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(providerRequestsProvider(token)),
          ),
        ],
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text('Failed to load requests'),
                  TextButton(
                    onPressed:
                        () => ref.refresh(providerRequestsProvider(token)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        data: (bookings) {
          print('📋 Provider bookings received: ${bookings.length}');
          print(
            '📦 First booking: ${bookings.isNotEmpty ? bookings.first : 'None'}',
          );

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No transport requests yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When clients book, they will appear here',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _ProviderBookingCard(
                booking: booking,
                token: token,
                formatter: formatter,
                onRefresh: () => ref.refresh(providerRequestsProvider(token)),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProviderBookingCard extends StatefulWidget {
  final Map<String, dynamic> booking;
  final String token;
  final NumberFormat formatter;
  final VoidCallback onRefresh;

  const _ProviderBookingCard({
    required this.booking,
    required this.token,
    required this.formatter,
    required this.onRefresh,
  });

  @override
  State<_ProviderBookingCard> createState() => _ProviderBookingCardState();
}

class _ProviderBookingCardState extends State<_ProviderBookingCard> {
  bool _loading = false;

  String get _status => widget.booking['status'] ?? 'requested';

  Future<void> _respond(String action) async {
    setState(() => _loading = true);
    try {
      final res = await http.patch(
        Uri.parse(AppUrls.respondToTransport(widget.booking['id'])),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'action': action}),
      );
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['status'] == true) {
        widget.onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'accept'
                  ? 'Booking accepted! Waiting for client payment.'
                  : 'Booking declined.',
            ),
            backgroundColor: action == 'accept' ? Colors.green : Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Color get _statusColor {
    switch (_status) {
      case 'accepted':
      case 'paid':
        return Colors.green;
      case 'declined':
      case 'cancelled':
        return Colors.red;
      case 'requested':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client info + status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    (widget.booking['client_name'] ?? 'C')[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.booking['client_name'] ?? 'Client',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.booking['client_phone'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                    _status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Route
            Row(
              children: [
                const Icon(Icons.my_location, size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.booking['pickup_location'] ?? '',
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.booking['dropoff_location'] ?? '',
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Distance and price
            Row(
              children: [
                Icon(Icons.straighten, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${widget.booking['distance_km']} km',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, size: 14, color: Colors.green),
                Text(
                  'UGX ${widget.formatter.format(double.tryParse(widget.booking['total_price'].toString()) ?? 0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ✅ Accept/Decline for new requests
            if (_status == 'requested')
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _respond('accept'),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _respond('decline'),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Decline'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),

            // ✅ Waiting for payment
            if (_status == 'accepted')
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_top, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Waiting for client to pay',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // ✅ Paid — ready to go
            if (_status == 'paid')
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Client has paid — ready to go!',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
