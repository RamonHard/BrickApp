import 'package:brickapp/models/product_model.dart';
import 'package:brickapp/pages/client_pages/gallery_view.dart';
import 'package:brickapp/providers/product_providers.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ViewSelectedProduct extends ConsumerWidget {
  const ViewSelectedProduct({super.key, required this.selectedProduct});
  final ProductModel selectedProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final featuredImages = ref.watch(feauturedImagesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Property Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  selectedProduct.productIMG,
                  width: width,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.favorite_border, color: Colors.red),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    height: 35,
                    width: 75,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.house, color: Colors.white),
                        Text(
                          "${selectedProduct.unitsNum}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.whiteTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            selectedProduct.isActive
                ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Rent now',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            MainNavigation.navigateToRoute(
                              MainNavigation.paymentMethodRoute,
                              data: selectedProduct,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text('Book'),
                        ),
                      ),
                    ],
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Currently Unavailable due to reasons like maintainance, under constraction, or renovations but you can book it ealier in advance.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedProduct.houseType,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    "UGX ${selectedProduct.price}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    selectedProduct.location,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Text('${selectedProduct.starRating} '),
                  Text(
                    '(${selectedProduct.reviews} reviews)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFeatureIcon(
                    Icons.bed,
                    '${selectedProduct.bedRoomNum} Beds',
                  ),
                  _buildFeatureIcon(Icons.weekend, 'Living Room'),
                  _buildFeatureIcon(Icons.park, 'Compound'),
                  _buildFeatureIcon(Icons.local_parking, 'Parking'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Featured Images',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 8),

            // 🔥 Featured Images from Provider
            Container(
              height: 120,
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => FullScreenView(
                                imageUrl: featuredImages[index].insideView,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      margin: EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          featuredImages[index].insideView,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            TextButton(
              onPressed: () {
                final featuredImages = ref.read(feauturedImagesProvider);
                final urls = featuredImages.map((e) => e.insideView).toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GalleryView(imageUrls: urls),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined),
                  SizedBox(width: 4),
                  Text('View All Photos'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Description',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextColor,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(selectedProduct.description),
            ),

            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      backgroundImage: NetworkImage(
                        selectedProduct.uploaderIMG,
                      ),
                    ),
                    title: Text(
                      selectedProduct.uploaderName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                    subtitle: Text(
                      'Property Manager',
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    MainNavigation.navigateToRoute(
                      MainNavigation.viewMoreProducts,
                      data: selectedProduct,
                    );
                  },
                  padding: EdgeInsets.all(8.0),
                  color: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'View More',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTextColor,
                    ),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.black),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class FullScreenView extends StatelessWidget {
  final String imageUrl;

  const FullScreenView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(child: InteractiveViewer(child: Image.network(imageUrl))),
    );
  }
}
