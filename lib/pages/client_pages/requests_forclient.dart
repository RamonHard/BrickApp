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

class RequestsByClient extends ConsumerWidget {
  const RequestsByClient({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final token = user.token ?? '';

    print('🔑 User token exists: ${token.isNotEmpty}');
    print(
      '🔑 Token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...',
    );

    final requestsAsync = ref.watch(clientRequestsProvider(token));
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
          'My Requests',
          style: GoogleFonts.actor(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('🔄 Manually refreshing...');
              ref.refresh(clientRequestsProvider(token));
            },
          ),
        ],
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          print('❌ Error loading requests: $error');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'Failed to load requests: ${error.toString()}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.refresh(clientRequestsProvider(token)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (bookings) {
          print('📊 Received ${bookings.length} bookings');

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your bookings will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
              print(
                '📦 Booking $index: ${booking['id']} - ${booking['booking_type']}',
              );
              return _ClientBookingCard(
                booking: booking,
                token: token,
                formatter: formatter,
                onRefresh: () => ref.refresh(clientRequestsProvider(token)),
              );
            },
          );
        },
      ),
    );
  }
}

class _ClientBookingCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> booking;
  final String token;
  final NumberFormat formatter;
  final VoidCallback onRefresh;

  const _ClientBookingCard({
    required this.booking,
    required this.token,
    required this.formatter,
    required this.onRefresh,
  });

  @override
  ConsumerState<_ClientBookingCard> createState() => _ClientBookingCardState();
}

class _ClientBookingCardState extends ConsumerState<_ClientBookingCard> {
  bool _loading = false;

  bool get _isProperty => widget.booking['booking_type'] == 'property';

  String get _status => widget.booking['status'] ?? 'pending';

  String get _escrowStatus => widget.booking['escrow_status'] ?? 'held';

  bool get _canRefund {
    // ✅ Only refundable if status is awaiting_visit and escrow is held
    if (_status != 'awaiting_visit') return false;
    if (_escrowStatus != 'held') return false;
    
    try {
      final bookedAt = DateTime.parse(widget.booking['booked_at'].toString());
      return DateTime.now().difference(bookedAt).inHours < 2;
    } catch (_) {
      return false;
    }
  }

  bool get _canConfirmVisit {
    return _status == 'awaiting_visit' && _escrowStatus == 'held';
  }

  String get _timeLeft {
    try {
      final bookedAt = DateTime.parse(widget.booking['booked_at'].toString());
      final minutesLeft = 120 - DateTime.now().difference(bookedAt).inMinutes;
      if (minutesLeft <= 0) return 'Refund window expired';
      if (minutesLeft > 60) {
        return '${minutesLeft ~/ 60}h ${minutesLeft % 60}m left to refund';
      }
      return '${minutesLeft}m left to refund';
    } catch (_) {
      return '';
    }
  }

  // ✅ Confirm property visit - releases money from escrow
  Future<void> _confirmVisit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Property Visit?'),
        content: const Text(
          'Have you visited the property and are you satisfied?\n\n'
          '⚠️ This will release the payment to the property manager.\n'
          'Only confirm if you have physically seen the property.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      final res = await http.patch(
        Uri.parse(AppUrls.confirmPropertyVisit(widget.booking['id'])),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['status'] == true) {
        widget.onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Visit confirmed! Payment released to manager.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to confirm visit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // ✅ Add these state variables to _PropertyBookingCardState
bool _isRequestingRefund = false;

// ✅ Add this method
Future<void> _requestRefund() async {
  final booking = widget.booking;
  
  // Check 72hr window
  final hoursSinceBooking = DateTime.now().difference(DateTime.parse(booking['created_at'] ?? DateTime.now().toIso8601String())).inHours;
  final hoursRemaining = 72 - hoursSinceBooking;
  
  if (hoursRemaining <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refund window has expired (72 hours)'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Reason selector
  String? selectedReason;
  final detailsController = TextEditingController();
  
  final reasons = [
    'Wrong location',
    'Fake listing',
    'Already occupied',
    'Different price',
    'Poor condition',
    'Missing amenities',
    'Other',
  ];

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: const Text('Request Refund'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 72hr countdown
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: hoursRemaining < 24 ? Colors.red[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hoursRemaining < 24 ? Colors.red[200]! : Colors.orange[200]!,
                  ),
                ),
                child: Row(children: [
                  Icon(Icons.timer, color: hoursRemaining < 24 ? Colors.red : Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'Refund window: ${hoursRemaining.toStringAsFixed(0)} hours remaining',
                    style: TextStyle(
                      color: hoursRemaining < 24 ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  )),
                ]),
              ),
              const SizedBox(height: 16),
              const Text('Reason for refund *',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...reasons.map((r) => RadioListTile<String>(
                value: r,
                groupValue: selectedReason,
                title: Text(r, style: const TextStyle(fontSize: 13)),
                activeColor: Colors.orange,
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (v) => setS(() => selectedReason = v),
              )).toList(),
              const SizedBox(height: 8),
              if (selectedReason == 'Other') ...[
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Please explain',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: const Text(
                  '⚠️ Only request a refund if you have visited the property and found it does not match the listing.',
                  style: TextStyle(color: Colors.red, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: selectedReason == null ? null : () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Submit Refund Request',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );

  if (confirmed != true || selectedReason == null || !mounted) return;

  setState(() => _isRequestingRefund = true);
  try {
    final token = ref.read(userProvider).token ?? '';
    final res = await http.post(
      Uri.parse('${AppUrls.baseUrl}/bookings/property/${booking['id']}/refund'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reason': selectedReason,
        'reason_details': detailsController.text.isEmpty ? null : detailsController.text,
      }),
    );

    if (!mounted) return;
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refund request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onRefresh(); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Failed'), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  }
  if (mounted) setState(() => _isRequestingRefund = false);
}

  Future<void> _payForTransport() async {
    setState(() => _loading = true);
    try {
      final res = await http.patch(
        Uri.parse(AppUrls.payForTransport(widget.booking['id'])),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['status'] == true) {
        widget.onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment confirmed! Driver is on the way.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Payment failed'),
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
      case 'visit_confirmed':
      case 'paid':
        return Colors.green;
      case 'cancelled':
      case 'declined':
        return Colors.red;
      case 'refund_requested':
      case 'refund_approved':
        return Colors.purple;
      case 'accepted':
        return Colors.blue;
      case 'awaiting_visit':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get _statusDisplay {
    switch (_status) {
      case 'awaiting_visit':
        return 'Awaiting Visit';
      case 'visit_confirmed':
        return 'Visit Confirmed ✅';
      case 'refund_requested':
        return 'Refund Requested';
      case 'refund_approved':
        return 'Refund Approved';
      default:
        return _status.replaceAll('_', ' ').toUpperCase();
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
            // Header row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      _isProperty ? Colors.orange[100] : Colors.blue[100],
                  child: Icon(
                    _isProperty ? Icons.home : Icons.local_shipping,
                    color: _isProperty ? Colors.orange[800] : Colors.blue[800],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.booking['item_name'] ?? 'Booking',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.booking['address'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status badge
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
                    _statusDisplay,
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

            // Owner info
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  widget.booking['owner_name'] ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  widget.booking['owner_phone'] ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Amount and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'UGX ${widget.formatter.format(double.tryParse(widget.booking['total_price'].toString()) ?? 0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                Text(
                  _formatDate(widget.booking['created_at']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ✅ ESCROW: Confirm Visit Button (for property bookings awaiting visit)
            if (_isProperty && _canConfirmVisit) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _confirmVisit,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirm Property Visit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              // ✅ Add after the Confirm Visit button inside the awaiting_visit section
const SizedBox(height: 8),
// 72hr countdown
Builder(builder: (ctx) {
  final hoursSince = DateTime.now().difference(DateTime.parse(widget.booking['created_at'] ?? DateTime.now().toIso8601String())).inHours;
  final hoursLeft = 72 - hoursSince;
  final isExpiring = hoursLeft < 24;
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: isExpiring ? Colors.red[50] : Colors.grey[50],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: isExpiring ? Colors.red[200]! : Colors.grey[200]!),
    ),
    child: Row(children: [
      Icon(Icons.timer_outlined, size: 14,
          color: isExpiring ? Colors.red : Colors.grey[600]),
      const SizedBox(width: 6),
      Expanded(child: Text(
        hoursLeft > 0
            ? 'Refund window: ${hoursLeft}h remaining'
            : 'Refund window expired',
        style: TextStyle(
          fontSize: 11,
          color: isExpiring ? Colors.red : Colors.grey[600],
          fontWeight: isExpiring ? FontWeight.w600 : FontWeight.normal,
        ),
      )),
    ]),
  );
}),
const SizedBox(height: 8),
// Refund button
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: _isRequestingRefund ? null : _requestRefund,
    icon: _isRequestingRefund
        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
        : const Icon(Icons.undo, size: 16, color: Colors.red),
    label: Text(
      _isRequestingRefund ? 'Requesting...' : 'Request Refund',
      style: const TextStyle(color: Colors.red),
    ),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.red),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.blue[700]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Only confirm after you have physically visited the property.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ✅ Refund for property bookings within 2 hours (only if still awaiting visit)
            if (_isProperty && _status == 'awaiting_visit') ...[
              if (_canRefund) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _requestRefund,
                    icon:
                        _loading
                            ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.undo, size: 16),
                    label: const Text('Request Refund'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer, size: 12, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(
                      _timeLeft,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Refund window expired (2 hours passed)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
            ],

            // ✅ Pay button for accepted transport bookings
            if (!_isProperty && _status == 'accepted') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _payForTransport,
                  icon:
                      _loading
                          ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.payment),
                  label: const Text('Pay Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],

            // ✅ Declined transport
            if (!_isProperty && _status == 'declined')
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Provider declined this request. Please try another vehicle.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            // ✅ Refund requested / approved status
            if (_status == 'refund_requested' || _status == 'refund_approved')
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _status == 'refund_approved' 
                          ? Icons.check_circle 
                          : Icons.hourglass_top,
                      size: 14,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _status == 'refund_approved'
                          ? 'Refund has been approved. Please wait for processing.'
                          : 'Refund request is being processed',
                      style: TextStyle(color: Colors.purple, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date.toString()));
    } catch (_) {
      return '';
    }
  }
}