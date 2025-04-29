import 'dart:ui';
import 'package:brickapp/pages/client_pages/filter_search.dart';
import 'package:brickapp/providers/product_providers.dart';
import 'package:brickapp/utils/app_images.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../custom_widgets/house_card.dart';
import '../../custom_widgets/search_field.dart';
import '../../models/product_model.dart';
import '../../utils/app_colors.dart';

class HomePage extends ConsumerWidget {
  HomePage({Key? key}) : super(key: key);
  final scaffoldState = GlobalKey<ScaffoldState>();
  final TextStyle style = GoogleFonts.actor(
    fontSize: 18,
    color: Colors.black,
    fontWeight: FontWeight.w800,
  );
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(productProvider);

    return SafeArea(
      child: Scaffold(
        key: scaffoldState,
        extendBodyBehindAppBar: true,
        drawerEnableOpenDragGesture: true,
        backgroundColor: Colors.transparent,
        body: NestedScrollView(
          headerSliverBuilder:
              ((hcontext, innerBoxIsScrolled) => [
                // SliverAppBar(
                //   floating: false,
                //   centerTitle: true,
                //   surfaceTintColor: Colors.transparent,
                //   elevation: 0,
                //   backgroundColor: Colors.transparent,
                //   leading: Container(),
                //   title: Text(
                //     "Brick App",
                //     style: style,
                //   ),
                // ),
              ]),
          body: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.backImg),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(child: Text("Brick App", style: style)),
                  const SizedBox(height: 10),
                  const SearchCard(
                    hintText:
                        'Search house by price,description.eg.selfcontained',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      bottom: 5.0,
                      top: 8.0,
                    ),
                    child: MaterialButton(
                      color: AppColors.iconColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FilterSearch(),
                          ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        "Sort by",
                        style: GoogleFonts.actor(
                          fontSize: 16,
                          color: HexColor('FFFFFF'),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: productList.length + 1,
                      itemBuilder: (BuildContext context, int indnex) {
                        if (indnex == productList.length) {
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Out of Search",
                              style: GoogleFonts.oxygen(
                                fontSize: 16,
                                color: HexColor('000000'),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        ProductModel productModel = productList[indnex];
                        return HouseCard(
                          profileIMG: productModel.uploaderIMG,
                          price: productModel.price,
                          location: productModel.location,
                          description: productModel.description,
                          productimage: productModel.productIMG,
                          onTap: () {
                            MainNavigation.navigateToRoute(
                              MainNavigation.viewSelectedProductRoute,
                              data: productModel,
                            );
                          },
                          id: 1,
                          uploaderName: productModel.uploaderName,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
