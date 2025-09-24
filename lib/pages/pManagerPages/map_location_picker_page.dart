import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapLocationPicker extends StatefulWidget {
  final Function(double, double, String) onLocationSelected;

  const MapLocationPicker({super.key, required this.onLocationSelected});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                widget.onLocationSelected(
                  _selectedLocation!.latitude,
                  _selectedLocation!.longitude,
                  _selectedAddress,
                );
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0.3476, 32.5825), // Kampala coordinates
              zoom: 12,
            ),
            onTap: (LatLng position) async {
              setState(() => _selectedLocation = position);
              await _getAddressFromCoordinates(position);
            },
            markers:
                _selectedLocation != null
                    ? {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: _selectedLocation!,
                      ),
                    }
                    : {},
          ),
          if (_selectedAddress.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(blurRadius: 4)],
                ),
                child: Text(_selectedAddress),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _getAddressFromCoordinates(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _selectedAddress = "${place.name}, ${place.locality}";
        });
      }
    } catch (e) {
      setState(() => _selectedAddress = "Address not available");
    }
  }
}
