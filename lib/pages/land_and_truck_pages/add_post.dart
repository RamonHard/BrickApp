import 'dart:io';
import 'package:brickapp/pages/land_and_truck_pages/full_screen_image_view.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import '../../custom_widgets/add_post_field.dart';
import '../../custom_widgets/description_card.dart';
import '../../utils/app_colors.dart';

class AddPost extends StatefulWidget {
  AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  TextStyle style = GoogleFonts.actor(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );
  TextStyle itemStyle = GoogleFonts.actor(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: HexColor("3d3d99"),
  );
  List<String> productItems = [
    'House',
    'Land',
    'Business Shop',
    'Ceremony Ground',
    'Hostel',
    'Office',
    'Lounge',
  ];
  List<String> location = ['Kampala', 'Kawempe', 'Newyork', 'Entebbe'];

  String? selectedProduct = 'House';
  String? selectLocation = 'Kampala';
  final bool isSuccess = true;
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageList = [];
  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageList!.addAll(selectedImages);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
          ),
          title: Text(
            "Add Post",
            style: GoogleFonts.actor(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          color: AppColors.backgroundColor,
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            primary: true,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Container()),
                    MaterialButton(
                      padding: EdgeInsets.all(8.0),
                      height: 40,
                      minWidth: 85,
                      onPressed: () {
                        MainNavigation.navigateToRoute(
                          MainNavigation.postTruckRoute,
                        );
                      },
                      color: AppColors.iconColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        "Post Truck",
                        style: GoogleFonts.actor(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: deviceSize / 10),
                Row(
                  children: [
                    Expanded(child: Text("Item: ", style: style)),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: SizedBox(
                          height: 50,
                          width: 280,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.iconColor,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            value: selectedProduct,
                            items:
                                productItems
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item, style: itemStyle),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                ((value) => setState(() {
                                  selectedProduct = value;
                                  print("GGGGGGGGGGGG ${selectedProduct}");
                                })),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Text("Location: ", style: style)),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: SizedBox(
                          height: 50,
                          width: 280,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.iconColor,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            value: selectLocation,
                            items:
                                location
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item, style: itemStyle),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                ((value) => setState(() {
                                  selectLocation = value;
                                })),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Text("Price: ", style: style)),
                    Expanded(flex: 2, child: AddPostField(hint: '20\$')),
                  ],
                ),
                Text('Description', style: style),
                DescriptionCard(
                  hint: 'e.g Three bed rooms, Parking space,\n Self contained,',
                ),
                Text('Add Images', style: style),
                Container(
                  height: 200,
                  child:
                      imageList.isEmpty
                          ? Container(
                            height: 200,
                            width: deviceSize,
                            child: InkWell(
                              onTap: selectImages,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    'No image selected.',
                                    style: GoogleFonts.actor(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.darkTextColor,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 40,
                                    child: Icon(
                                      Icons.add_a_photo_outlined,
                                      color: AppColors.darkTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : GridView.builder(
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                ),
                            itemCount: imageList.length + 1,
                            itemBuilder: (context, index) {
                              if (index == imageList.length) {
                                return InkWell(
                                  onTap: selectImages,
                                  child: Container(
                                    color: const Color.fromARGB(
                                      31,
                                      158,
                                      158,
                                      158,
                                    ),
                                    height: 20,
                                    width: 20,
                                    child: const Icon(Icons.add, size: 35),
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
                                  child: Container(
                                    width: deviceSize,
                                    height: 200,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Image.file(
                                        height: 200,
                                        File(imageList[index].path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (BuildContext context) =>
                                                FullScreenImageView(
                                                  imageList: imageList,
                                                  imageIndex: index,
                                                ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    alignment: Alignment.center,
                    child: MaterialButton(
                      height: 45,
                      minWidth: 100,
                      onPressed: () {
                        final snackBar = SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: Container(
                            padding: EdgeInsets.all(8.0),
                            height: 60,
                            decoration: BoxDecoration(
                              color:
                                  isSuccess
                                      ? AppColors.iconColor.withOpacity(0.4)
                                      : AppColors.darkBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child:
                                      isSuccess
                                          ? Text(
                                            "Success!!",
                                            style: GoogleFonts.actor(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          )
                                          : Text(
                                            "Warning!!",
                                            style: GoogleFonts.actor(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red,
                                            ),
                                          ),
                                ),
                                Container(
                                  child:
                                      isSuccess
                                          ? Text(
                                            "Your post has been uploaded.",
                                            style: GoogleFonts.actor(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          )
                                          : Text(
                                            "Failed to upload",
                                            style: GoogleFonts.actor(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red,
                                            ),
                                          ),
                                ),
                              ],
                            ),
                          ),
                        );
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
                        isSuccess ? Navigator.pop(context) : null;
                      },
                      color: AppColors.buttonColor,
                      padding: EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Submmit",
                        style: GoogleFonts.actor(
                          fontSize: 16,
                          color: HexColor("ffffff"),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
