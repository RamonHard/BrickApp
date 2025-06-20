import 'package:brickapp/providers/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends ConsumerWidget {
  const DateTimePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: booking.selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (pickedDate != null) {
                bookingNotifier.setSelectedDate(pickedDate);
              }
            },
            child: Text(
              booking.selectedDate == null
                  ? 'Select Date'
                  : DateFormat('MMM dd, yyyy').format(booking.selectedDate!),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: booking.selectedTime ?? TimeOfDay.now(),
              );
              if (pickedTime != null) {
                bookingNotifier.setSelectedTime(pickedTime);
              }
            },
            child: Text(
              booking.selectedTime == null
                  ? 'Select Time'
                  : booking.selectedTime!.format(context),
            ),
          ),
        ),
      ],
    );
  }
}
