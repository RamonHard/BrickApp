import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerPage extends StatefulWidget {
  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? selectedPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick Location')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(0.3476, 32.5825), // Kampala default
          zoom: 14,
        ),
        onTap: (LatLng position) {
          setState(() {
            selectedPosition = position;
          });
        },
        markers:
            selectedPosition != null
                ? {
                  Marker(
                    markerId: MarkerId("selected"),
                    position: selectedPosition!,
                  ),
                }
                : {},
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (selectedPosition != null) {
            Navigator.pop(context, selectedPosition);
          }
        },
        label: Text(
          "Select Location",
          style: GoogleFonts.poppins(
            color: AppColors.orangeTextColor,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        icon: Icon(Icons.check, color: AppColors.iconColor),
      ),
    );
  }
}
