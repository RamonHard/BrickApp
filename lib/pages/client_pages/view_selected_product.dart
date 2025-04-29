import 'package:brickapp/models/product_model.dart';
import 'package:brickapp/pages/client_pages/view_more_products.dart';
import 'package:brickapp/providers/product_providers.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/house_views_model.dart';
import 'full_screen_view.dart';

class ViewSelectedProduct extends ConsumerWidget {
  ViewSelectedProduct({super.key, required this.selectedProduct});

  final ProductModel selectedProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final productViewList = ref.watch(productProvider);
    final featuredImageList = ref.watch(feauturedImagesProvider);

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
          ),
        ),
        body: SingleChildScrollView(
          primary: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                      child: Container(
                        height: height * 1 / 2.5,
                        width: width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(selectedProduct.productIMG),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                      ),
                      height: 50,
                      child: ListTile(
                        leading: Text(
                          "Rent now",
                          style: GoogleFonts.actor(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.iconColor,
                          ),
                        ),
                        trailing: MaterialButton(
                          onPressed: () {
                            MainNavigation.navigateToRoute(
                              MainNavigation.bookingPageRoute,
                              data: selectedProduct,
                            );
                          },
                          padding: EdgeInsets.all(4.0),
                          height: 40,
                          minWidth: 100,
                          color: AppColors.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            "Book",
                            style: GoogleFonts.actor(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: HexColor("FFFFFF"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Text(
                  "Location:",
                  style: GoogleFonts.actor(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
                title: Text(
                  selectedProduct.location,
                  style: GoogleFonts.actor(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
                trailing: MaterialButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (BuildContext context) => MapScreen(),
                    //   ),
                    // );
                  },
                  color: AppColors.iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    "View Location",
                    style: GoogleFonts.actor(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightTextColor,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Text(
                  "Price:",
                  style: GoogleFonts.actor(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
                title: Text(
                  "UGX ${selectedProduct.price}",
                  style: GoogleFonts.actor(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.iconColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  selectedProduct.description,
                  maxLines: 5,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.actor(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Featured Images",
                  style: GoogleFonts.actor(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
              ),
              Container(
                height: 220,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: productViewList.length,
                  itemBuilder: (BuildContext context, int index) {
                    HouseViewsModel houseViewsModel = featuredImageList[index];
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => FullScreenView(
                                    imageUrl: houseViewsModel.insideView,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          height: 200,
                          width: 200,
                          child: Image.network(
                            houseViewsModel.insideView,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // SizedBox(
              //   height: height * 1 / 25,
              // ),
              Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => ViewMoreProducts(
                              name: selectedProduct.uploaderName,
                              image: selectedProduct.uploaderIMG,
                              email: selectedProduct.uploaderEmail,
                              phone: selectedProduct.uploaderPhoneNumber,
                              iconicHouseIMG: selectedProduct.productIMG,
                            ),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    height: 50,
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: HexColor("E67E22"),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "View More",
                          style: GoogleFonts.actor(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.camera, color: HexColor("FFFFFF")),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 1 / 20),
            ],
          ),
        ),
      ),
    );
  }
}
