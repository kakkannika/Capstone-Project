// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/ui/theme/theme.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:tourism_app/utils/routing_utils.dart';

class TripMapScreen extends StatefulWidget {
  final String tripId;
  final String dayId;

  const TripMapScreen({
    super.key,
    required this.tripId,
    required this.dayId,
  });

  @override
  _TripMapScreenState createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = false;
  SmartRoutingResult? _routingResult;
  bool _isDirectFallbackRoute = false;
  String? _focusedPlaceId; // Track which place is currently focused
  bool _isCardCollapsed = true; // Track if the bottom card is collapsed
  bool _isRouteOptimized = false; // Track if route is optimized
  List<Place> _places = []; // Store all places
  LatLng? _currentUserLocation; // Store the user's current location
  bool _isTrackingLocation = false; // Track if we're monitoring location
  bool _isFollowingUser = false; // Track if the map should follow the user
  StreamSubscription<Position>?
      _positionStreamSubscription; // For tracking location updates

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Location services are disabled. Please enable them.')),
      );
      return;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission still denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied. Please enable them in settings.'),
        ),
      );
      return;
    }

    // Permission granted, but don't start tracking automatically
    // User will need to press the tracking button to start
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      // Load places without optimizing
      _places = await _getPlacesForDay(tripProvider);

      if (_places.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No places found for this day')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Just show the places without optimizing using numbered markers
      await _updateMapWithNumberedMarkers(_places, optimized: false);

      setState(() {
        _isLoading = false;
        _isRouteOptimized = false; // Always start with optimization disabled
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading places: $e')),
      );
    }
  }

  void _startLocationTracking() {
    // If already tracking, don't restart
    if (_isTrackingLocation == true) {
      return;
    }

    // Create location settings
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update location if moved at least 10 meters
    );

    // Start listening to position updates
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        final bool isFirstUpdate = _currentUserLocation == null;

        setState(() {
          _currentUserLocation = LatLng(position.latitude, position.longitude);
        });

        _updateUserLocationMarker();

        // Only focus on first update if we're following
        if (isFirstUpdate && _isFollowingUser) {
          _focusOnUserLocation();
        }
        // Otherwise only focus if we're following and not the first update
        else if (_isFollowingUser) {
          _focusOnUserLocation();
        }

        // If route is optimized, update it with new location
        if (_isRouteOptimized) {
          _fetchPlacesAndCalculateRoute();
        }
      },
      onError: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location tracking error: $e')),
        );
      },
    );
  }

  void _updateUserLocationMarker() {
    if (_currentUserLocation == null) return;

    // Create a user location marker
    final userMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: _currentUserLocation!,
      infoWindow: const InfoWindow(title: 'Your Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      zIndex:
          10, // Very high zIndex to ensure it's visible above all other markers
      alpha: 1.0, // Fully opaque
      flat: false, // 3D marker (stands up from the map)
      anchor: const Offset(0.5, 0.5), // Center the marker
    );

    setState(() {
      // Remove existing user marker if any
      _markers
          .removeWhere((marker) => marker.markerId.value == 'user_location');
      // Add new user marker
      _markers.add(userMarker);
    });

    // Move camera to user location if following is enabled
    if (_mapController != null && _isFollowingUser) {
      _focusOnUserLocation();
    }
  }

  void _toggleLocationTracking() {
    // Toggle tracking state
    bool newTrackingState = !_isTrackingLocation;

    if (newTrackingState) {
      // Turning tracking ON
      setState(() {
        _isTrackingLocation = true;
        _isFollowingUser = true;
      });

      // Show message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location tracking enabled')),
      );

      // Start tracking in background
      _startLocationTracking();

      // Get current position and focus on it
      Geolocator.getCurrentPosition().then((position) {
        if (mounted) {
          setState(() {
            _currentUserLocation =
                LatLng(position.latitude, position.longitude);
          });
          _updateUserLocationMarker();

          // Focus after a slight delay to ensure marker is created
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted &&
                _mapController != null &&
                _currentUserLocation != null) {
              _focusOnUserLocation();
            }
          });
        }
      }).catchError((e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error getting current location: $e')),
          );
        }
      });
    } else {
      // Turning tracking OFF
      setState(() {
        _isTrackingLocation = false;
        _isFollowingUser = false;
      });

      // Cancel position stream subscription
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;

      // Show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location tracking disabled')),
      );

      // When we stop tracking, zoom out to show all markers
      if (_mapController != null && _markers.isNotEmpty) {
        _zoomToFitMarkers();
      }
    }
  }

  void _toggleFollowUser() {
    if (!_isTrackingLocation) {
      // Can't follow if not tracking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turn on location tracking first')),
      );
      return;
    }

    setState(() {
      _isFollowingUser = !_isFollowingUser;

      if (_isFollowingUser) {
        // Focus on user's location when turning on following
        _focusOnUserLocation();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Following your location')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stopped following your location')),
        );
      }
    });
  }

  void _focusOnUserLocation() {
    if (_mapController == null || _currentUserLocation == null) {
      return;
    }

    // Animate to user's current position with a smooth animation
    _mapController!
        .animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentUserLocation!,
              zoom: 16.0, // Higher zoom level for better visibility
              tilt: 0, // No tilt
              bearing: 0, // North up
            ),
          ),
        )
        .then((_) {})
        .catchError((e) {
      print("Error animating camera: $e");
    });
  }

  void _toggleRouteOptimization() async {
    if (_isRouteOptimized) {
      // If already optimized, revert to normal view
      setState(() {
        _isLoading = true; // Show loading while reverting
      });

      // Use regular markers for normal view
      await _updateMapWithNumberedMarkers(_places, optimized: false);

      setState(() {
        _isRouteOptimized = false;
        _routingResult = null;
        _polylines = {};
        _isLoading = false;
      });
    } else {
      // Optimize the route
      setState(() {
        _isLoading = true;
      });

      await _fetchPlacesAndCalculateRoute();

      setState(() {
        _isRouteOptimized = true;
        _isLoading = false;
      });
    }

    // Ensure user location marker is still showing if tracking is enabled
    if (_isTrackingLocation && _currentUserLocation != null) {
      _updateUserLocationMarker();
    }
  }

  Future<void> _fetchPlacesAndCalculateRoute() async {
    setState(() {
      _isDirectFallbackRoute = false;
    });

    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);

      // Listen for places in the selected day
      final places = await _getPlacesForDay(tripProvider);

      if (places.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No places found for this day')),
        );
        return;
      }

      // Calculate the optimal route starting from user's current location
      final result = await _calculateRouteFromCurrentLocation(places);

      // Check if this is likely a direct fallback route
      if (result.polylinePoints.length < 5) {
        setState(() {
          _isDirectFallbackRoute = true;
        });
      }

      // Update state with routing result
      setState(() {
        _routingResult = result;
        _polylines = {}; // Clear existing polylines
      });

      // Add polyline for the route
      _updateRoutePolyline(result);

      // Update markers with numbers based on optimized order
      await _updateMapWithNumberedMarkers(result.optimizedRoute,
          optimized: true);

      // Make sure current location marker appears on top if tracking is enabled
      if (_isTrackingLocation && _currentUserLocation != null) {
        _updateUserLocationMarker();
      }

      // Zoom to fit all markers
      _zoomToFitMarkers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<SmartRoutingResult> _calculateRouteFromCurrentLocation(
      List<Place> places) async {
    // Only use current location if tracking is enabled
    if (!_isTrackingLocation || _currentUserLocation == null) {
      // If location tracking is disabled or location is not available,
      // just optimize the places without using current location
      return await SmartRoutingUtil.calculateOptimalRoute(places,
          transportMode: 'driving');
    }

    // Create a virtual "current location" place
    final currentLocationPlace = Place(
      id: 'current_location',
      name: 'Your Location',
      description: 'Your current location',
      location: firestore.GeoPoint(
          _currentUserLocation!.latitude, _currentUserLocation!.longitude),
      imageURL: 'https://maps.google.com/mapfiles/ms/icons/blue-dot.png',
      category: 'current_location',
      averageRating: 0,
      entranceFees: 0,
      openingHours: '24h',
      province: 'Current Location',
    );

    // Add current location as the first place to visit
    final placesWithCurrentLocation = [currentLocationPlace, ...places];

    // Calculate route with current location included
    final result = await SmartRoutingUtil.calculateOptimalRoute(
        placesWithCurrentLocation,
        transportMode: 'driving');

    // If successful, the result should have our current location as the first place
    if (result.optimizedRoute.isNotEmpty &&
        result.optimizedRoute[0].id == 'current_location') {
      // Remove current location from the result to avoid showing it in the UI list
      // but keep it in the polyline for routing
      final optimizedRouteWithoutCurrentLocation =
          result.optimizedRoute.sublist(1);

      return SmartRoutingResult(
        optimizedRoute: optimizedRouteWithoutCurrentLocation,
        totalDistance: result.totalDistance,
        polylinePoints: result.polylinePoints,
      );
    }

    // If something went wrong, return the original result
    return result;
  }

  void _updateRoutePolyline(SmartRoutingResult result) {
    // Set polyline color based on transport mode
    Color polylineColor = Colors.blue.shade700;

    // Add polyline connecting all places in order
    if (result.polylinePoints.isNotEmpty) {
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: result.polylinePoints,
        color: polylineColor,
        width: 4,
        patterns: [
          PatternItem.dash(10),
          PatternItem.gap(5),
        ],
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
      );

      setState(() {
        _polylines.add(polyline);
      });
    }
  }

  Future<List<Place>> _getPlacesForDay(TripProvider tripProvider) async {
    final placesStream = tripProvider.getPlacesForDayStream(
      tripId: widget.tripId,
      dayId: widget.dayId,
    );

    // Convert stream to a list
    final places = await placesStream.first;
    return places;
  }

  void _zoomToFitMarkers() {
    if (_mapController == null || _markers.isEmpty) return;

    // Calculate bounds that include all markers
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in _markers) {
      final pos = marker.position;
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    // Add padding to the bounds
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - 0.01, minLng - 0.01),
      northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
    );

    // Animate camera to show all markers
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _moveToLocation(Place place) {
    if (_mapController == null) return;

    setState(() {
      _focusedPlaceId = place.id;
    });

    final CameraPosition newPosition = CameraPosition(
      target: LatLng(place.location.latitude, place.location.longitude),
      zoom: 16.0, // Zoom in closer to see the place details
    );

    _mapController!.animateCamera(CameraUpdate.newCameraPosition(newPosition));

    // Also update the marker to bounce or highlight it
    _highlightMarker(place);
  }

  void _highlightMarker(Place place) {
    // If on a real device with more capabilities, you could implement bouncing markers
    // or other animations here. For simplicity, we just move to the marker.
    _mapController?.showMarkerInfoWindow(MarkerId(place.id));
  }

  // Update the list tile to be clickable to move the map view
  Widget _buildPlaceListItem(
      int index, Place place, PlaceType placeType, Color typeColor) {
    final bool isSelected = _focusedPlaceId == place.id;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? typeColor.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: typeColor, width: 1) : null,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor,
          child: Text('${index + 1}'),
        ),
        title: Text(
          place.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          _getPlaceTypeLabel(placeType),
          style: TextStyle(
            color: typeColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => _moveToLocation(place),
        trailing: isSelected ? Icon(Icons.location_on, color: typeColor) : null,
      ),
    );
  }

  String _getPlaceTypeLabel(PlaceType placeType) {
    switch (placeType) {
      case PlaceType.hotel:
        return 'Hotel/Accommodation';
      case PlaceType.attraction:
        return 'Attraction';
      case PlaceType.foodAndBeverage:
        return 'Food & Beverage';
    }
  }

  Color _getPlaceTypeColor(PlaceType placeType) {
    switch (placeType) {
      case PlaceType.hotel:
        return Colors.purple;
      case PlaceType.attraction:
        return Colors.blue;
      case PlaceType.foodAndBeverage:
        return Colors.red;
    }
  }

  // Adding a method to create custom numbered markers with standard pin shape
  Future<BitmapDescriptor> _createNumberedMarker(
      int number, Color color) async {
    // Create a picture recorder
    final pictureRecorder = ui.PictureRecorder();
    final canvas = ui.Canvas(pictureRecorder);
    const size = 200.0; // Larger size for better quality

    // Calculate center for drawing
    const center = size / 2;

    // Draw the standard pin marker (teardrop shape)
    final path = Path()
      ..moveTo(center, size * 0.20) // Top of the pin
      ..quadraticBezierTo(
          size * 0.70, size * 0.15, size * 0.70, size * 0.40) // Top right curve
      ..quadraticBezierTo(
          size * 0.70, size * 0.70, center, size * 0.90) // Bottom right curve
      ..quadraticBezierTo(size * 0.30, size * 0.70, size * 0.30,
          size * 0.40) // Bottom left curve
      ..quadraticBezierTo(
          size * 0.30, size * 0.15, center, size * 0.20); // Top left curve

    // Fill the path with color
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Add letter/number in white
    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 80, // Larger font
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(center - textPainter.width / 2,
            size * 0.40 - textPainter.height / 2 // Position centered in the pin
            ));

    // Convert to image
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      // Fall back to default markers if custom creation fails
      return BitmapDescriptor.defaultMarkerWithHue(color == Colors.blue
          ? BitmapDescriptor.hueBlue
          : color == Colors.red
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueViolet);
    }

    final bytes = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
  }

  // Adding a method to use custom icons (for both optimized and unoptimized views)
  Future<void> _updateMapWithNumberedMarkers(List<Place> places,
      {bool optimized = false}) async {
    // Clear existing markers
    _markers = {};

    // Add markers for each place
    for (var i = 0; i < places.length; i++) {
      final place = places[i];
      final placeType = SmartRoutingUtil.getPlaceType(place);

      // Skip the current location place in the numbered markers
      if (place.id == 'current_location') {
        continue;
      }

      if (optimized) {
        // For optimized view, use custom numbered markers
        // Choose marker color based on place type
        Color markerColor;
        switch (placeType) {
          case PlaceType.hotel:
            markerColor = Colors.purple;
          case PlaceType.attraction:
            markerColor = Colors.blue;
          case PlaceType.foodAndBeverage:
            markerColor = Colors.red;
        }

        // Create numbered marker icon
        final markerIcon = await _createNumberedMarker(i + 1, markerColor);

        final marker = Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.location.latitude, place.location.longitude),
          infoWindow: InfoWindow(
            title: '${i + 1}. ${place.name}',
            snippet: place.description.length > 50
                ? '${place.description.substring(0, 50)}...'
                : place.description,
          ),
          icon: markerIcon,
          onTap: () {
            setState(() {
              _focusedPlaceId = place.id;
            });
          },
        );

        _markers.add(marker);
      } else {
        // For regular view, use standard Google Maps markers
        BitmapDescriptor markerIcon;
        switch (placeType) {
          case PlaceType.hotel:
            markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet);
          case PlaceType.attraction:
            markerIcon =
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
          case PlaceType.foodAndBeverage:
            markerIcon =
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        }

        final marker = Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.location.latitude, place.location.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.description.length > 50
                ? '${place.description.substring(0, 50)}...'
                : place.description,
          ),
          icon: markerIcon,
          onTap: () {
            setState(() {
              _focusedPlaceId = place.id;
            });
          },
        );

        _markers.add(marker);
      }
    }

    // If tracking location, add the current location marker
    if (_isTrackingLocation && _currentUserLocation != null) {
      _updateUserLocationMarker();
    }

    // Fit markers on map
    _zoomToFitMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DertamColors.white,
      appBar: AppBar(
        backgroundColor: DertamColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Smart move with dertam',
          style:
              TextStyle(color: DertamColors.black),
        ),
        iconTheme: IconThemeData(color: DertamColors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlaces,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Location tracking toggle button
          FloatingActionButton(
            heroTag: 'location_tracking_button',
            onPressed: () {
              // If not tracking yet, enable tracking and focus on current location
              if (!_isTrackingLocation) {
                setState(() {
                  _isTrackingLocation = true;
                  _isFollowingUser = true;
                });

                // Show loading message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Getting your location...')),
                );

                // Get current position for accuracy
                Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                ).then((currentPosition) {
                  setState(() {
                    _currentUserLocation = LatLng(
                        currentPosition.latitude, currentPosition.longitude);
                  });

                  // First update the marker, then focus on it
                  _updateUserLocationMarker();

                  // Delay the focus slightly to ensure the marker is rendered
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _focusOnUserLocation();
                  });

                  // Start continuous tracking
                  _startLocationTracking();

                  // Show message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location tracking enabled')),
                  );
                }).catchError((e) {
                  setState(() {
                    _isTrackingLocation = false;
                    _isFollowingUser = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error getting current location: $e')),
                  );
                });
              } else {
                // If already tracking, just toggle the tracking state
                _toggleLocationTracking();
              }
            },
            backgroundColor: _isTrackingLocation
                ? Colors.blue.shade600
                : Colors.grey.shade400,
            mini: true,
            tooltip: _isTrackingLocation
                ? 'Disable location tracking'
                : 'Enable location tracking',
            child: Icon(
              _isTrackingLocation ? Icons.location_on : Icons.location_off,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Follow user toggle button (only visible when tracking is on)
          if (_isTrackingLocation)
            FloatingActionButton(
              heroTag: 'follow_user_button',
              onPressed: _toggleFollowUser,
              backgroundColor: _isFollowingUser
                  ? Colors.amber.shade600
                  : Colors.grey.shade400,
              mini: true,
              tooltip:
                  _isFollowingUser ? 'Stop following' : 'Follow my location',
              child: Icon(
                _isFollowingUser ? Icons.navigation : Icons.navigation_outlined,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 16),
          // Route optimization button
          FloatingActionButton.extended(
            heroTag: 'route_optimization_button',
            onPressed: _toggleRouteOptimization,
            backgroundColor: _isRouteOptimized
                ? Colors.green.shade700
                : DertamColors.primary,
            icon: Icon(
              _isRouteOptimized ? Icons.check_circle : Icons.route,
              color: Colors.white,
            ),
            label: Text(
              _isRouteOptimized ? 'Optimized' : 'Optimize Route',
              style: TextStyle(
                  color: DertamColors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target:
                  LatLng(11.5564, 104.9282), // Default to Cambodia coordinates
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              if (_markers.isNotEmpty) {
                _zoomToFitMarkers();
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // We'll use our own buttons
            mapToolbarEnabled: false, // Simpler UI
            zoomControlsEnabled: false, // We'll use gestures for zoom
            trafficEnabled: false,
          ),

          // Current location info banner
          if (_isTrackingLocation &&
              _isRouteOptimized &&
              _currentUserLocation != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: DertamColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:  Row(
                  children: [
                    Icon(Icons.location_on, color: DertamColors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Starting from your current location',
                        style: TextStyle(
                            color: DertamColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Warning banner for direct routing
          if (_isDirectFallbackRoute && !_isLoading && _isRouteOptimized)
            Positioned(
              top: _isTrackingLocation
                  ? 68
                  : 16, // Position below current location banner if it's showing
              left: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:  Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: DertamColors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Direct route may cross water',
                        style: TextStyle(
                            color: DertamColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF0D3E4C)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isRouteOptimized
                              ? 'Optimizing route...'
                              : 'Loading places...',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Route info card
          if (_routingResult != null && !_isLoading && _isRouteOptimized)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Collapse/Expand Handle
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCardCollapsed = !_isCardCollapsed;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isCardCollapsed
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),

                  // Main Card
                  ClipRect(
                    child: GestureDetector(
                      onTap: () {
                        if (_isCardCollapsed) {
                          setState(() {
                            _isCardCollapsed = false;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: _isCardCollapsed ? 56 : null,
                        curve: Curves.easeInOut,
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(0),
                              bottom: Radius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: _isCardCollapsed ? 8.0 : 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.route,
                                            size: 20, color: Color(0xFF0D3E4C)),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Optimal Route',
                                          style: _isCardCollapsed
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)
                                              : Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D3E4C)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Total: ${_routingResult!.totalDistance.toStringAsFixed(2)} km',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0D3E4C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (!_isCardCollapsed) ...[
                                  const SizedBox(height: 16),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height:
                                        180, // Taller to show more destinations
                                    child: ListView.builder(
                                      itemCount:
                                          _routingResult!.optimizedRoute.length,
                                      itemBuilder: (context, index) {
                                        final place = _routingResult!
                                            .optimizedRoute[index];
                                        // Skip current location in the list
                                        if (place.id == 'current_location') {
                                          return const SizedBox.shrink();
                                        }

                                        final placeType =
                                            SmartRoutingUtil.getPlaceType(
                                                place);

                                        // Calculate display index (subtract 1 if there's a current location place before this one)
                                        final displayIndex = _routingResult!
                                                .optimizedRoute
                                                .any((p) =>
                                                    p.id ==
                                                        'current_location' &&
                                                    _routingResult!
                                                            .optimizedRoute
                                                            .indexOf(p) <
                                                        index)
                                            ? index - 1
                                            : index;

                                        return _buildPlaceListItem(
                                            displayIndex,
                                            place,
                                            placeType,
                                            _getPlaceTypeColor(placeType));
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper function to get minimum of two values
  int min(int a, int b) => a < b ? a : b;
}
