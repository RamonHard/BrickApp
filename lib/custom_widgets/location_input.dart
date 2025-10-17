import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationInput extends StatefulWidget {
  final Function(String) onLocationSelected;
  final String hintText;
  final EdgeInsets contentPadding;
  const LocationInput({
    super.key,
    required this.onLocationSelected,
    required this.hintText,
    required this.contentPadding,
  });

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied'),
          ),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String address = [
          if (placemark.street != null) placemark.street,
          if (placemark.subLocality != null) placemark.subLocality,
          if (placemark.locality != null) placemark.locality,
          if (placemark.postalCode != null) placemark.postalCode,
          if (placemark.country != null) placemark.country,
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        _controller.text = address;
        widget.onLocationSelected(address);
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.hintText,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: widget.contentPadding,
            ),
            onChanged: (value) {
              widget.onLocationSelected(value);
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon:
              _isLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.my_location),
          onPressed: _getCurrentLocation,
        ),
      ],
    );
  }
}
