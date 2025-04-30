import 'package:brickapp/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApartmentBookingPage extends StatelessWidget {
  const ApartmentBookingPage({super.key, required this.productModel});
  final ProductModel productModel;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booking Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              productModel.productIMG,
              width: width,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productModel.houseType,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${productModel.starRating}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${productModel.reviews} reviews)',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${productModel.location}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Features Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 4,
                    children: [
                      FeatureItem(
                        icon: Icons.bed,
                        text: '${productModel.bedRoomNum} bedrooms',
                      ),
                      FeatureItem(
                        icon: Icons.attach_money,
                        text: '\$${productModel.price}/month',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Divider(),
                  const SizedBox(height: 16),

                  // Payment Method Section
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Payment Options
                  PaymentOption(
                    title: 'Pay with Airtel',
                    icon: Icons.phone_android,
                    onSelected: () {
                      // Handle Airtel payment selection
                    },
                  ),
                  const SizedBox(height: 8),
                  PaymentOption(
                    title: 'Pay with MTN',
                    icon: Icons.phone_android,
                    onSelected: () {
                      // Handle MTN payment selection
                    },
                  ),
                  const SizedBox(height: 24),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Handle booking
                      },
                      child: const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 18),
                      ),
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

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

class PaymentOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onSelected;

  const PaymentOption({
    super.key,
    required this.title,
    required this.icon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onSelected,
      ),
    );
  }
}
