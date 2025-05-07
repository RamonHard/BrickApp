import 'package:flutter/material.dart';

class PriceDemo extends StatefulWidget {
  @override
  _PriceDemoState createState() => _PriceDemoState();
}

class _PriceDemoState extends State<PriceDemo> {
  final List<String> packages = ['1 Month', '2 Months', '3 Months'];
  String? selectedPackage;
  int? price;
  int? discount;
  int? commission;

  void showPriceDialog(String pkg) {
    final priceController = TextEditingController(text: '600000');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Set Price'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Enter Price'),
                ),
                SizedBox(height: 16),
                Text('Selected Package: $pkg'),
                SizedBox(height: 8),
                Text('Price: UGX550,000'),
                Text('Discount: UGX30,000'),
                Text('Commission: UGX20,000'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final enteredPrice = int.tryParse(priceController.text) ?? 0;
                  setState(() {
                    selectedPackage = pkg;
                    price = enteredPrice;
                    discount = (enteredPrice * 0.05).toInt(); // 5% discount
                    commission = (enteredPrice * 0.03).toInt(); // 3% commission
                  });
                  Navigator.pop(context);
                },
                child: Text('Done'),
              ),
            ],
          ),
    );
  }

  Widget buildPackageCard(String pkg) {
    return GestureDetector(
      onTap: () => showPriceDialog(pkg),
      child: Card(
        color: selectedPackage == pkg ? Colors.blueAccent : Colors.white,
        child: Padding(padding: const EdgeInsets.all(16.0), child: Text(pkg)),
      ),
    );
  }

  Widget buildSelectedInfo() {
    if (selectedPackage == null) return SizedBox();

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected Package: $selectedPackage'),
          Text('Price: UGX${price?.toStringAsFixed(0)}'),
          Text('Discount: UGX${discount?.toStringAsFixed(0)}'),
          Text('Commission: UGX${commission?.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Package Pricing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: packages.map(buildPackageCard).toList(),
              ),
            ),
            buildSelectedInfo(),
          ],
        ),
      ),
    );
  }
}
