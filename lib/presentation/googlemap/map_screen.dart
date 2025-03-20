import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/providers/google_map_service.dart';
import 'dart:async';

class MapNavigationScreen extends StatefulWidget {
  final GeoPoint destinationLocation;
  final String destinationName;

  const MapNavigationScreen({
    super.key,
    required this.destinationLocation,
    required this.destinationName,
  });

  @override
  _MapNavigationScreenState createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _locationService = Location();
  final DirectionsService _directionsService = DirectionsService();

  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  String _distance = 'Calculating...';
  String _duration = 'Calculating...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    // Check if location service is enabled
    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await _locationService.getLocation();
    setState(() {
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
      _getDirections();
    });
  }

  Future<void> _getDirections() async {
    if (_currentLocation == null) return;

    // Convert GeoPoint to LatLng
    final LatLng destinationLatLng = LatLng(widget.destinationLocation.latitude,
        widget.destinationLocation.longitude);

    // Add markers
    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: destinationLatLng,
        infoWindow: InfoWindow(title: widget.destinationName),
      ),
    );

    // Get directions
    final directions = await _directionsService.getDirections(
      origin: _currentLocation!,
      destination: destinationLatLng,
    );

    // Create a polyline
    final List<LatLng> polylineCoordinates = directions['polylineCoordinates'];

    if (polylineCoordinates.isNotEmpty) {
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        );

        _distance = directions['distance'];
        _duration = directions['duration'];
        _isLoading = false;
      });

      // Adjust camera to show the route
      _fitBounds(polylineCoordinates);
    }
  }

  Future<void> _fitBounds(List<LatLng> points) async {
    if (points.isEmpty) return;

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100, // padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.destinationName),
      ),
      body: Stack(
        children: [
          _currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    setState(() {
                      _isLoading = false; // Update UI only after map is ready
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? LatLng(0, 0), // Ensure valid default
                    zoom: 15,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
          if (!_isLoading)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: SingleChildScrollView( // Wrap with SingleChildScrollView to prevent overflow
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.destinationName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Distance: $_distance'),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, size: 16),
                            Text('Duration: $_duration'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
