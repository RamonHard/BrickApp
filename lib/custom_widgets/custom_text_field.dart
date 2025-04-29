import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../utils/app_colors.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({super.key, required this.hintText});
  final String hintText;
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;
  FocusNode? _focusNode;
  bool _isObsecure = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    _focusNode!.addListener(() {
      setState(() {
        _isFocused = _focusNode!.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNode!.dispose();
  }

  void _toggleObsecure() {
    setState(() {
      _isObsecure = !_isObsecure;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor =
        _isFocused ? AppColors.iconColor : HexColor("CDCDCD");
    return Container(
      height: 50,
      child: TextField(
        style: GoogleFonts.oxygen(color: Colors.white, fontSize: 18),
        obscureText: _isObsecure,
        focusNode: _focusNode,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: iconColor,
          ),
          suffixIcon: GestureDetector(
            onTap: _toggleObsecure,
            child: Icon(
              _isObsecure ? Icons.visibility : Icons.visibility_off,
              color: iconColor,
            ),
          ),
          hintText: '${widget.hintText}',
          hintStyle: GoogleFonts.oxygen(color: Colors.white, fontSize: 16),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(100),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}
