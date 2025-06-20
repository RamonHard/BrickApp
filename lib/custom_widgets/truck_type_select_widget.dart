import 'package:brickapp/providers/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TruckTypeSelector extends ConsumerWidget {
  const TruckTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);

    final List<String> truckTypes = [
      'Small Truck (up to 1.5 tons)',
      'Medium Truck (1.5-5 tons)',
      'Large Truck (5+ tons)',
      'Refrigerated Truck',
      'Flatbed Truck',
    ];

    return Column(
      children:
          truckTypes.map((type) {
            return RadioListTile<String>(
              title: Text(type),
              value: type,
              groupValue: booking.selectedTruckType,
              onChanged: (value) {
                bookingNotifier.setSelectedTruckType(value!);
              },
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
    );
  }
}
