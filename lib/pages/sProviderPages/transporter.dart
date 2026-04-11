import 'dart:convert';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TransportBookingPage extends ConsumerStatefulWidget {
  const TransportBookingPage({super.key});

  @override
  ConsumerState<TransportBookingPage> createState() =>
      _TransportBookingPageState();
}

class _TransportBookingPageState extends ConsumerState<TransportBookingPage> {
  final formatter = NumberFormat('#,###');

  // Step tracking
  int _currentStep = 0; // 0=locations, 1=truck type, 2=confirm

  // Location inputs
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _distanceController = TextEditingController();

  // Selected truck type
  Map<String, dynamic>? _selectedType;
  List<Map<String, dynamic>> _truckTypes = [];
  bool _loadingTypes = false;

  // Calculated price
  Map<String, dynamic>? _priceResult;
  bool _calculatingPrice = false;

  // Booking
  bool _isBooking = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _loadTruckTypes() async {
    setState(() => _loadingTypes = true);
    try {
      final res = await http.get(Uri.parse(AppUrls.truckTypes));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _truckTypes = List<Map<String, dynamic>>.from(data['types']);
        });
      }
    } catch (e) {
      _showSnack('Failed to load truck types: $e', Colors.red);
    }
    setState(() => _loadingTypes = false);
  }

  Future<void> _calculatePrice() async {
    if (_selectedType == null) {
      _showSnack('Please select a truck type first', Colors.red);
      return;
    }

    final distance = double.tryParse(_distanceController.text);
    if (distance == null || distance <= 0) {
      _showSnack('Please enter a valid distance', Colors.red);
      return;
    }

    setState(() => _calculatingPrice = true);
    try {
      final res = await http.post(
        Uri.parse(AppUrls.calculateTransport),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vehicle_type_id':
              _selectedType!['id'], // Use vehicle_type_id instead
          'distance_km': distance,
        }),
      );

      print("Price calculation response: ${res.statusCode}");
      print("Response body: ${res.body}");

      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);

        // Check if the response has the expected fields from your backend
        if (data.containsKey('total') && data.containsKey('price_per_km')) {
          // Transform the response to match what your UI expects
          setState(() {
            _priceResult = {
              'price_per_km': data['price_per_km'],
              'distance_km': data['distance_km'],
              'total_price': data['total'], // Map 'total' to 'total_price'
              'subtotal': data['subtotal'],
              'commission': data['commission'],
              'commission_percent': data['commission_percent'],
              'vehicle_type': data['vehicle_type'],
            };
          });
          _showSnack('Price calculated successfully', Colors.green);
        } else {
          _showSnack('Invalid response format from server', Colors.red);
          print("Unexpected response structure: $data");
        }
      } else {
        _showSnack('Failed to calculate price (${res.statusCode})', Colors.red);
      }
    } catch (e) {
      print("Error calculating price: $e");
      _showSnack('Failed to calculate price: $e', Colors.red);
    }
    setState(() => _calculatingPrice = false);
  }

  Future<void> _sendBookingRequest() async {
    setState(() => _isBooking = true);

    try {
      final token = ref.read(userProvider).token;

      // Validate price result exists
      if (_priceResult == null) {
        _showSnack(
          'Price not calculated. Please go back and calculate again.',
          Colors.red,
        );
        setState(() => _isBooking = false);
        return;
      }

      final body = {
        'vehicle_type_id': _selectedType!['id'], // Use vehicle_type_id
        'pickup_location': _pickupController.text.trim(),
        'dropoff_location': _dropoffController.text.trim(),
        'distance_km': double.tryParse(_distanceController.text) ?? 0,
        'price_per_km': _priceResult!['price_per_km'] ?? 0,
        'total_price': _priceResult!['total_price'] ?? 0, // This is now mapped
      };

      print("SENDING BODY: $body");

      final res = await http.post(
        Uri.parse(AppUrls.bookTransport),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("Booking response status: ${res.statusCode}");
      print("Booking response body: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['status'] == true) {
        _showSuccessDialog();
      } else {
        _showSnack(data['message'] ?? 'Booking failed', Colors.red);
      }
    } catch (e) {
      print("Error in booking: $e");
      _showSnack('Error: $e', Colors.red);
    } finally {
      setState(() => _isBooking = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_shipping, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Booking Sent!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'UGX ${formatter.format(_priceResult!['total_price'])}', // Now works
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⏳ Waiting for a driver to accept your request. You\'ll be notified once accepted — then you can pay.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book a Truck',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () async {
          if (_currentStep == 0) {
            // Validate locations
            if (_pickupController.text.isEmpty ||
                _dropoffController.text.isEmpty ||
                _distanceController.text.isEmpty) {
              _showSnack('Please fill in all location fields', Colors.red);
              return;
            }
            await _loadTruckTypes();
            setState(() => _currentStep = 1);
          } else if (_currentStep == 1) {
            if (_selectedType == null) {
              _showSnack('Please select a truck type', Colors.red);
              return;
            }
            await _calculatePrice();
            setState(() => _currentStep = 2);
          } else {
            // Final step — show payment
            _showConfirmDialog();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _isBooking ? null : details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.iconColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child:
                      _isBooking
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            _currentStep == 2 ? 'Send Request' : 'Continue',
                          ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // ─── Step 1: Locations ──────────────────────
          Step(
            title: const Text('Enter Locations'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                // Pickup
                TextField(
                  controller: _pickupController,
                  decoration: InputDecoration(
                    labelText: 'Pickup Location',
                    hintText: 'e.g. Kampala, Nakasero',
                    prefixIcon: const Icon(
                      Icons.my_location,
                      color: Colors.green,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Dropoff
                TextField(
                  controller: _dropoffController,
                  decoration: InputDecoration(
                    labelText: 'Dropoff Location',
                    hintText: 'e.g. Entebbe, Airport',
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Distance
                TextField(
                  controller: _distanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Estimated Distance (km)',
                    hintText: 'e.g. 25',
                    suffixText: 'km',
                    prefixIcon: const Icon(
                      Icons.straighten,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    helperText:
                        'Enter the approximate distance between locations',
                  ),
                ),
              ],
            ),
          ),

          // ─── Step 2: Truck Type ─────────────────────
          // ─── Step 2: Truck Type ─────────────────────
          Step(
            title: const Text('Select Vehicle Type'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content:
                _loadingTypes
                    ? const Center(child: CircularProgressIndicator())
                    : _truckTypes.isEmpty
                    ? Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_shipping,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No vehicles available right now.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const Text(
                            'Please try again later.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                    : Column(
                      children:
                          _truckTypes.map((type) {
                            final isSelected =
                                _selectedType?['id'] == type['id'];
                            final pricePerKm = type['price_per_km'];
                            final distance =
                                double.tryParse(_distanceController.text) ?? 0;
                            final estimated = pricePerKm * distance;
                            final vehicles = List<Map<String, dynamic>>.from(
                              type['vehicles'] ?? [],
                            );

                            return GestureDetector(
                              onTap: () => setState(() => _selectedType = type),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.orange[50]
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.orange
                                            : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // ─── Type header ───────────────
                                    Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          // Icon
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? Colors.orange[100]
                                                      : Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              _getTypeIcon(type['name']),
                                              color:
                                                  isSelected
                                                      ? Colors.orange
                                                      : Colors.grey,
                                              size: 26,
                                            ),
                                          ),
                                          const SizedBox(width: 14),

                                          // Type info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  type['name'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color:
                                                        isSelected
                                                            ? Colors.orange[800]
                                                            : Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  'UGX ${formatter.format(pricePerKm)}/km',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                if (distance > 0)
                                                  Text(
                                                    'Est. UGX ${formatter.format(estimated)}',
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),

                                          // Available count + check
                                          Column(
                                            children: [
                                              Text(
                                                '${type['available_count']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              const Text(
                                                'available',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              if (isSelected)
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.orange,
                                                  size: 20,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ─── Vehicle list ───────────────
                                    if (vehicles.isNotEmpty) ...[
                                      Divider(
                                        height: 1,
                                        color: Colors.grey[200],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          14,
                                          8,
                                          14,
                                          12,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Available vehicles:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ...vehicles.map(
                                              (v) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 6,
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Vehicle photo or icon
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[100],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        image:
                                                            v['photo_url'] !=
                                                                        null &&
                                                                    v['photo_url']
                                                                        .toString()
                                                                        .isNotEmpty
                                                                ? DecorationImage(
                                                                  image: NetworkImage(
                                                                    '${AppUrls.baseUrl}/${v['photo_url']}',
                                                                  ),
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                )
                                                                : null,
                                                      ),
                                                      child:
                                                          v['photo_url'] ==
                                                                      null ||
                                                                  v['photo_url']
                                                                      .toString()
                                                                      .isEmpty
                                                              ? Icon(
                                                                Icons
                                                                    .local_shipping,
                                                                color:
                                                                    Colors
                                                                        .grey[400],
                                                                size: 20,
                                                              )
                                                              : null,
                                                    ),
                                                    const SizedBox(width: 10),

                                                    // Driver + plate
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            v['owner_name'] ??
                                                                'Driver',
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 13,
                                                                ),
                                                          ),
                                                          Text(
                                                            '${v['brand'] ?? ''} • ${v['plate_number'] ?? ''}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                            ),
                                                          ),
                                                          if (v['capacity'] !=
                                                                  null &&
                                                              v['capacity']
                                                                  .toString()
                                                                  .isNotEmpty)
                                                            Text(
                                                              'Capacity: ${v['capacity']}',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color:
                                                                    Colors
                                                                        .grey[500],
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Available badge
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 3,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              Colors
                                                                  .green[200]!,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Available',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Colors.green[700],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                          }).toList(),
                    ),
          ),

          // ─── Step 3: Confirm ────────────────────────
          Step(
            title: const Text('Confirm & Pay'),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
            content:
                _calculatingPrice
                    ? const Center(child: CircularProgressIndicator())
                    : _priceResult == null
                    ? const Text('Price not calculated')
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Route summary
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.my_location,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _pickupController.text,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Padding(
                                padding: EdgeInsets.only(left: 7),
                                child: Icon(
                                  Icons.more_vert,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _dropoffController.text,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Price breakdown
                        _buildPriceRow(
                          'Truck type',
                          _selectedType?['name'] ?? '',
                        ),
                        _buildPriceRow(
                          'Distance',
                          '${_priceResult!['distance_km']} km',
                        ),
                        _buildPriceRow(
                          'Price per km',
                          'UGX ${formatter.format(_priceResult!['price_per_km'])}',
                        ),
                        const Divider(),
                        _buildPriceRow(
                          'Total',
                          'UGX ${formatter.format(_priceResult!['total_price'])}',
                          isBold: true,
                          color: Colors.deepOrange,
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '💡 You\'ll only pay after a driver accepts your request.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? Colors.black,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Booking Request'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${_selectedType?['name']}'),
                Text('${_pickupController.text} → ${_dropoffController.text}'),
                Text('${_priceResult!['distance_km']} km'),
                const Divider(),
                Text(
                  'UGX ${formatter.format(_priceResult!['total_price'])}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '💡 You\'ll pay AFTER a driver accepts your request.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _sendBookingRequest(); // ✅ correct
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Send Request'),
              ),
            ],
          ),
    );
  }

  IconData _getTypeIcon(String name) {
    switch (name) {
      case 'Small Truck':
        return Icons.local_shipping;
      case 'Medium Truck':
        return Icons.fire_truck;
      case 'Large Truck':
        return Icons.airport_shuttle;
      case 'Trailer':
        return Icons.rv_hookup;
      case 'Bus':
        return Icons.directions_bus;
      case 'Costa':
        return Icons.directions_bus_filled;
      default:
        return Icons.local_shipping;
    }
  }
}
