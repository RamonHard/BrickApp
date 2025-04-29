import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../utils/app_colors.dart';

class DescriptionCard extends StatelessWidget {
  const DescriptionCard({Key? key, required this.hint}) : super(key: key);
  final String hint;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        bottom: 15.0,
        top: 8.0,
      ),
      child: Container(
        height: 200,
        child: Card(
          elevation: 4,
          color: Colors.white,
          child: TextFormField(
            expands: true,
            maxLines: null,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: EdgeInsets.all(8.0),
              isCollapsed: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: AppColors.iconColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
