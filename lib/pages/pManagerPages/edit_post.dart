import 'package:brickapp/custom_widgets/add_post_field.dart';
import 'package:brickapp/custom_widgets/description_card.dart';
import 'package:brickapp/models/destination_model.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class EditPostPage extends StatelessWidget {
  const EditPostPage({super.key, required this.editPostModel});
  final MoreProductViewModel editPostModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            MainNavigation.navigateToRoute(MainNavigation.postViewRoute);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
        ),
        centerTitle: true,
        title: Text(
          "Edit Post",
          style: GoogleFonts.actor(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(editPostModel.img),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Price: ",
                          style: GoogleFonts.actor(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: AddPostField(hint: '${editPostModel.price}'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Location: ",
                          style: GoogleFonts.actor(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 50,
                          child: TextFormField(
                            style: GoogleFonts.ptSerif(
                              color: HexColor("3d3d99"),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            keyboardType: TextInputType.number,
                            expands: true,
                            maxLines: null,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(8.0),
                              suffixIcon: Icon(
                                Icons.location_on,
                                color: AppColors.textColor,
                              ),
                              hintStyle: GoogleFonts.ptSerif(
                                color: HexColor("3d3d99"),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              hintText: editPostModel.location,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.iconColor,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Description',
                    style: GoogleFonts.actor(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  Container(
                    height: 200,
                    child: DescriptionCard(hint: editPostModel.description),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            MaterialButton(
              height: 50,
              minWidth: 150,
              color: AppColors.iconColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              onPressed: () {},
              child: Text(
                "Save Changes",
                style: GoogleFonts.actor(
                  color: AppColors.lightTextColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
