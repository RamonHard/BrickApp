import 'dart:ui';
import 'package:brickapp/custom_widgets/house_card.dart';
import 'package:brickapp/models/product_model.dart';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/client_pages/detailed_house_view.dart';
import 'package:brickapp/providers/product_provider.dart';
import 'package:brickapp/providers/property_providers.dart';
import 'package:brickapp/providers/view_more_product_provider.dart';
import 'package:brickapp/utils/build_image_method.dart';
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

  final PropertyModel productModel;
  TextStyle style = GoogleFonts.oxygen(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: HexColor("FFFFFF"),
  );
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;

    // ✅ Fetch properties by owner from backend
    final ownerPropertiesAsync = ref.watch(
      ownerPropertiesFamilyProvider(productModel.userId ?? 0),
    );

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
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
                  ),
                ),
              ]),
          body: Column(
            children: [
              // Header with uploader info
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
                        child: buildImage(
                          productModel.thumbnail,
                          width: 120,
                          height: 100,
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
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(36.0),
                          bottomRight: Radius.circular(36.0),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        child:
                            productModel.uploaderIMG.isNotEmpty
                                ? null
                                : const Icon(Icons.person, size: 40),
                        backgroundImage:
                            productModel.uploaderIMG.isNotEmpty
                                ? NetworkImage(productModel.uploaderIMG)
                                : null,
                      ),
                      title: Text(productModel.uploaderName, style: style),
                      // subtitle: Text(
                      //   productModel.ownerPhone ?? '',
                      //   style: style.copyWith(fontSize: 13),
                      // ),
                    ),
                  ],
                ),
              ),

              // Properties list
              Expanded(
                child: ownerPropertiesAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (err, _) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Failed to load properties'),
                            TextButton(
                              onPressed:
                                  () => ref.refresh(
                                    ownerPropertiesFamilyProvider(
                                      productModel.userId ?? 0,
                                    ),
                                  ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                  data: (properties) {
                    if (properties.isEmpty) {
                      return const Center(
                        child: Text('No other properties from this owner'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: properties.length,
                      itemBuilder: (BuildContext context, int index) {
                        final property = properties[index];
                        return HouseCard(
                          profileIMG: '',
                          price: property.displayPrice,
                          location: property.location,
                          description: property.description,
                          thumbnail: property.thumbnailUrl ?? '',
                          houseType: property.propertyType,
                          isActive: property.status == 'active',
                          id: property.id,
                          uploaderName: property.ownerName ?? '',
                          unitsNum: property.units,
                          bedroomNum: property.bedrooms,
                          starRating: 0,
                          reviews: 0,
                          sqft: property.sqft,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (BuildContext context) => DetailedHouseView(
                                      selectedProduct: property,
                                    ),
                              ),
                            );
                          },
                          showDelete: false,
                        );
                      },
                    );
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
