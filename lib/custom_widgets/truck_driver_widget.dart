// widgets/truck_driver_card.dart
import 'package:brickapp/models/truck_driver_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TruckDriverCard extends StatelessWidget {
  final TruckDriver driver;

  const TruckDriverCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(driver.imageUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driver.truckNumber,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      RatingBarIndicator(
                        rating: driver.rating,
                        itemBuilder:
                            (context, index) =>
                                const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 20,
                        direction: Axis.horizontal,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '\$${driver.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${driver.distance.toStringAsFixed(1)} km away',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  driver.truckType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // In a real app, this would confirm the booking
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Confirm Booking'),
                            content: Text(
                              'Confirm booking with ${driver.name} for \$${driver.price.toStringAsFixed(2)}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Booking confirmed with ${driver.name}',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: const Text('Book Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
