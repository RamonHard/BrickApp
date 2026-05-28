import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocationPicker extends StatefulWidget {
  final Function(double lat, double lng, String address) onLocationSelected;
  final LatLng? initialLocation;

  const MapLocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();

  LatLng _selectedLocation = const LatLng(0.3476, 32.5825); // Kampala
  String _selectedAddress = 'Kampala, Uganda';
  bool _isLoading = false;
  bool _isMapReady = false;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation!;
    }
    _updateMarker(_selectedLocation);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _moveToLocation(LatLng(position.latitude, position.longitude));
    } catch (e) {
      print('Location error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _moveToLocation(LatLng latLng) async {
    setState(() => _selectedLocation = latLng);
    _updateMarker(latLng);

    if (_isMapReady && _controller.isCompleted) {
      final controller = await _controller.future;
      await controller.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 16));
    }

    // Reverse geocode to get address
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).toList();
        setState(() =>
            _selectedAddress = parts.isNotEmpty ? parts.join(', ') : 'Unknown');
      }
    } catch (e) {
      setState(() => _selectedAddress =
          '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}');
    }
  }

  void _updateMarker(LatLng latLng) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected'),
          position: latLng,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange),
          onDragEnd: (newPos) => _moveToLocation(newPos),
          infoWindow: InfoWindow(title: _selectedAddress),
        ),
      };
    });
  }

  Future<void> _searchByQuery(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        await _moveToLocation(LatLng(loc.latitude, loc.longitude));
        _searchController.clear();
      } else {
        _showSnack('Location not found');
      }
    } catch (e) {
      _showSnack('Could not find location');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _confirmLocation() {
    widget.onLocationSelected(
      _selectedLocation.latitude,
      _selectedLocation.longitude,
      _selectedAddress,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Location',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _confirmLocation,
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Confirm',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ─── Map ─────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _controller.complete(controller);
              setState(() => _isMapReady = true);
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            onTap: (latLng) => _moveToLocation(latLng),
          ),

          // ─── Loading overlay ──────────────────────────
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
            ),

          // ─── Search Bar ───────────────────────────────
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search area, district or address...',
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.orange),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                textInputAction: TextInputAction.search,
                onChanged: (v) => setState(() {}),
                onSubmitted: _searchByQuery,
              ),
            ),
          ),

          // ─── My Location button ───────────────────────
          Positioned(
            bottom: 190,
            right: 12,
            child: FloatingActionButton.small(
              heroTag: 'my_location',
              backgroundColor: Colors.white,
              onPressed: _getCurrentLocation,
              child:
                  const Icon(Icons.my_location, color: Colors.orange),
            ),
          ),

          // ─── Selected Location Card ───────────────────
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border:
                    Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.location_on,
                            color: Colors.orange, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Selected Location',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedAddress,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'Tap map or drag pin to change location',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Confirm Location',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}