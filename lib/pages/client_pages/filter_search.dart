import 'package:brickapp/pages/client_pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../utils/app_colors.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';

class FilterSearch extends StatefulWidget {
  const FilterSearch({super.key});

  @override
  State<FilterSearch> createState() => _FilterSearchState();
}

class _FilterSearchState extends State<FilterSearch> {
  MultiSelectItemDecorations selectItemDecorations = MultiSelectItemDecorations(
    selectedDecoration: BoxDecoration(
      color: AppColors.iconColor,
      borderRadius: BorderRadius.circular(100),
    ),
    decoration: BoxDecoration(
      color: HexColor("ABB2B9"),
      borderRadius: BorderRadius.circular(100),
    ),
  );
  MultiSelectItemTextStyles filterTextStyle = MultiSelectItemTextStyles(
    selectedTextStyle: GoogleFonts.actor(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextColor,
    ),
    disabledTextStyle: GoogleFonts.actor(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextColor,
    ),
  );
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
          ),
          title: Text(
            "Filter",
            style: GoogleFonts.actor(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 8.0),
                child: Text(
                  "Selecte Description",
                  style: GoogleFonts.actor(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: MultiSelectContainer(
                  animations: MultiSelectAnimations(
                    labeAnimationlCurve: Curves.easeIn,
                  ),
                  alignments: const MultiSelectAlignments(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                  highlightColor: HexColor("FFFFFF"),
                  textStyles: MultiSelectTextStyles(
                    textStyle: GoogleFonts.actor(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  itemsPadding: const EdgeInsets.all(8.0),
                  items: [
                    MultiSelectCard(
                      textStyles: filterTextStyle,
                      decorations: selectItemDecorations,
                      value: 'Self Contained',
                      label: 'Self Contained',
                    ),
                    MultiSelectCard(
                      textStyles: filterTextStyle,
                      decorations: selectItemDecorations,
                      value: 'Business Shop',
                      label: 'Business Shop',
                    ),
                    MultiSelectCard(
                      textStyles: filterTextStyle,
                      decorations: selectItemDecorations,
                      value: 'Flat Appartments',
                      label: 'Flat Appartments',
                    ),
                    MultiSelectCard(
                      textStyles: filterTextStyle,
                      decorations: selectItemDecorations,
                      value: 'Events',
                      label: 'Events',
                    ),
                    MultiSelectCard(
                      textStyles: filterTextStyle,
                      decorations: selectItemDecorations,
                      value: 'Hostels',
                      label: 'Hostels',
                    ),
                    MultiSelectCard(
                      textStyles: filterTextStyle,
                      decorations: selectItemDecorations,
                      value: 'Offices',
                      label: 'Offices',
                    ),
                    MultiSelectCard(
                      textStyles: filterTextStyle,
                      decorations: selectItemDecorations,
                      value: 'Lounges',
                      label: 'Lounges',
                    ),
                  ],
                  onChange: (allSelectedItems, selectedItem) {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Selecte Price Range",
                  style: GoogleFonts.actor(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "From",
                style: GoogleFonts.actor(
                  fontSize: deviceWidth / 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkTextColor,
                ),
              ),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: HexColor("ABB2B9"),
                ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.ptSerif(
                    fontSize: deviceWidth / 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkTextColor,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusColor: Colors.transparent,
                    disabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'UGX 1000',
                    hintStyle: GoogleFonts.ptSerif(
                      fontSize: deviceWidth / 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextColor,
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "To",
                style: GoogleFonts.actor(
                  fontSize: deviceWidth / 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkTextColor,
                ),
              ),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: HexColor("ABB2B9"),
                ),
                child: TextFormField(
                  style: GoogleFonts.ptSerif(
                    fontSize: deviceWidth / 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkTextColor,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusColor: Colors.transparent,
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'UGX 2000',
                    hintStyle: GoogleFonts.ptSerif(
                      fontSize: deviceWidth / 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextColor,
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(
                  alignment: Alignment.center,
                  child: MaterialButton(
                    height: 45,
                    minWidth: 100,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    color: AppColors.buttonColor,
                    padding: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Search",
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
    );
  }
}
