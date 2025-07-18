import 'package:brickapp/custom_widgets/view_posts_card.dart';
import 'package:brickapp/models/destination_model.dart';
import 'package:brickapp/providers/view_more_product_provider.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../custom_widgets/house_card.dart';
import '../../custom_widgets/search_field.dart';
import '../../utils/app_colors.dart';

class ViewYourPosts extends ConsumerWidget {
  ViewYourPosts({Key? key}) : super(key: key);
  final TextStyle style = GoogleFonts.actor(
    fontSize: 18,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moreProductiewList = ref.watch(viewMoreProductProvider);
    return SafeArea(
      child: Scaffold(
        floatingActionButton: MaterialButton(
          color: AppColors.iconColor,
          minWidth: 50,
          height: 50,

          shape: CircleBorder(side: BorderSide(color: AppColors.iconColor)),
          onPressed: () {
            MainNavigation.navigateToRoute(MainNavigation.postTruckRoute);
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.backgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text("Posts", style: style),
        ),
        backgroundColor: AppColors.backgroundColor,
        body: Container(
          color: AppColors.backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: SearchCard(hintText: 'Search house'),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: moreProductiewList.length,
                  itemBuilder: (BuildContext context, int indnex) {
                    MoreProductViewModel moreProductViewModel =
                        moreProductiewList[indnex];
                    return ViewPostsCard(
                      price: moreProductViewModel.price,
                      location: moreProductViewModel.location,
                      description: moreProductViewModel.description,
                      productimage: moreProductViewModel.img,
                      editBtn: () {
                        MainNavigation.navigateToRoute(
                          MainNavigation.editPostPae,
                          data: moreProductViewModel,
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
