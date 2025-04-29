import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../utils/app_colors.dart';

class PasswordGlassField extends HookWidget {
  PasswordGlassField({
    super.key,
    this.onChanged,
    this.onSaved,
    this.validator,
  });
  final Function(String?)? onChanged;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final isObsecure = useState(true);
    return Container(
      height: 50,
      child: TextFormField(
        obscureText: isObsecure.value,
        style: GoogleFonts.actor(
            fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBg),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              isObsecure.value = !isObsecure.value;
            },
            icon: Icon(
              isObsecure.value ? Icons.visibility_off : Icons.visibility,
              color: AppColors.iconColor,
            ),
          ),
          filled: true,
          fillColor: HexColor("FFFFFF").withOpacity(0.5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: HexColor("FFFFFF").withOpacity(0.6),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: HexColor("FFFFFF").withOpacity(0.6),
            ),
          ),
        ),
        onChanged: onChanged,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}
