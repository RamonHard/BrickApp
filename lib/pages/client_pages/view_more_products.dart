import 'dart:ui';
import 'package:brickapp/custom_widgets/house_card.dart';
import 'package:brickapp/models/product_model.dart';
import 'package:brickapp/pages/client_pages/detailed_house_view.dart';
import 'package:brickapp/providers/view_more_product_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../custom_widgets/destination_card.dart';
import '../../models/destination_model.dart';
import '../../utils/app_colors.dart';

// ignore: must_be_immutable
class ViewMoreProducts extends ConsumerWidget {
  ViewMoreProducts({Key? key, required this.productModel}) : super(key: key);

  final ProductModel productModel;
  TextStyle style = GoogleFonts.oxygen(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: HexColor("FFFFFF"),
  );
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final moreProductViewList = ref.watch(viewMoreProductProvider);
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.backgroundColor,
        body: NestedScrollView(
          headerSliverBuilder:
              ((context, innerBoxIsScrolled) => [
                SliverAppBar(
                  elevation: 0,
                  floating: false,
                  pinned: false,
                  backgroundColor: AppColors.appBarColor,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
                  ),
                ),
              ]),
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.appBarColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36.0),
                    bottomRight: Radius.circular(36.0),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: width,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(36.0),
                          bottomRight: Radius.circular(36.0),
                        ),
                        child: Image.network(
                          productModel.productIMG,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      child: BackdropFilter(
                        child: Container(color: Colors.transparent),
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 2),
                      ),
                    ),
                    Container(
                      height: 140,
                      width: width,
                      child: Text(""),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(36.0),
                          bottomRight: Radius.circular(36.0),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(productModel.uploaderIMG),
                      ),
                      title: Text(productModel.uploaderName, style: style),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: moreProductViewList.length,
                  itemBuilder: (BuildContext context, int index) {
                    MoreProductViewModel moreProductViewModel =
                        moreProductViewList[index];
                    return HouseCard(
                      profileIMG: productModel.uploaderIMG,
                      price: moreProductViewModel.price,
                      location: moreProductViewModel.location,
                      description: moreProductViewModel.description,
                      productimage: moreProductViewModel.img,
                      houseType: moreProductViewModel.houseType,
                      isActive: moreProductViewModel.isActive,
                      id: 1,
                      uploaderName: productModel.uploaderName,
                      unitsNum: moreProductViewModel.unitsNum,
                      bedroomNum: moreProductViewModel.bedRoomNum,
                      starRating: moreProductViewModel.starRating,
                      reviews: moreProductViewModel.reviews,
                      sqft: moreProductViewModel.sqft,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (BuildContext context) => DetailedHouseView(
                                  selectedProduct: moreProductViewModel,
                                ),
                          ),
                        );
                      },
                    );
                    // ProductCard(
                    //   price: moreProductViewModel.price,
                    //   location: moreProductViewModel.location,
                    //   id: moreProductViewModel.id,
                    //   img: moreProductViewModel.img,
                    //   description: moreProductViewModel.description,
                    //   onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder:
                    //         (BuildContext context) => DetailedHouseView(
                    //           selectedProduct: moreProductViewModel,
                    //         ),
                    //   ),
                    // );
                    //   },
                    // );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
