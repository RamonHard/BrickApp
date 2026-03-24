import 'package:brickapp/providers/request_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class RequestsForPropertyManager extends ConsumerWidget {
  const RequestsForPropertyManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(userProvider).token ?? '';
    final requestsAsync = ref.watch(managerRequestsProvider(token));
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
          'Property Requests',
          style: GoogleFonts.actor(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(managerRequestsProvider(token)),
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
                        () => ref.refresh(managerRequestsProvider(token)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No booking requests yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
              final status = booking['status'] ?? 'confirmed';
              Color statusColor;
              switch (status) {
                case 'confirmed':
                  statusColor = Colors.green;
                  break;
                case 'refund_requested':
                  statusColor = Colors.purple;
                  break;
                case 'refunded':
                  statusColor = Colors.grey;
                  break;
                case 'cancelled':
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.orange;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Client info
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange[100],
                            child: Text(
                              (booking['client_name'] ?? 'C')[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking['client_name'] ?? 'Client',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  booking['client_phone'] ?? '',
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
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              status.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Property info
                      Row(
                        children: [
                          const Icon(Icons.home, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${booking['property_type'] ?? ''} • ${booking['address'] ?? ''}',
                              style: const TextStyle(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Dates
                      if (booking['start_date'] != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_formatDate(booking['start_date'])} → ${_formatDate(booking['end_date'])}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                size: 16,
                                color: Colors.grey,
                              ),
                              Text(
                                'UGX ${formatter.format(double.tryParse(booking['total_price'].toString()) ?? 0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatDate(booking['created_at']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),

                      // Refund requested notice
                      if (status == 'refund_requested') ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple[200]!),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.purple,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Client has requested a refund for this booking.',
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      return DateTime.parse(date.toString()).toString().substring(0, 10);
    } catch (_) {
      return '-';
    }
  }
}
