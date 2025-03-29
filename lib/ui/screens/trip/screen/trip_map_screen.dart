import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';
import 'package:tourism_app/utils/routing_util.dart';
import 'dart:ui' as ui;

class TripMapScreen extends StatefulWidget {
  final String tripId;
  final String dayId;

  const TripMapScreen({
    Key? key,
    required this.tripId,
    required this.dayId,
  }) : super(key: key);

  @override
  _TripMapScreenState createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = false;
  SmartRoutingResult? _routingResult;
  String _selectedTransportMode = 'driving';
  bool _isDirectFallbackRoute = false;
  String? _focusedPlaceId; // Track which place is currently focused
  bool _isCardCollapsed = true; // Track if the bottom card is collapsed
  bool _isRouteOptimized = false; // Track if route is optimized
  List<Place> _places = []; // Store all places
  
  // Transport mode options
  final List<Map<String, dynamic>> _transportModes = [
    {'mode': 'driving', 'icon': Icons.directions_car, 'label': 'Driving'},
    {'mode': 'walking', 'icon': Icons.directions_walk, 'label': 'Walking'},
    {'mode': 'bicycling', 'icon': Icons.directions_bike, 'label': 'Biking'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPlaces();
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
      await _updateMapWithNumberedMarkers(_places);
      setState(() {
        _isLoading = false;
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
  
  void _updateMapWithPlaces(List<Place> places) {
    // Clear existing markers
    _markers = {};
    
    // Add markers for each place
    for (var i = 0; i < places.length; i++) {
      final place = places[i];
      final placeType = SmartRoutingUtil.getPlaceType(place);
      
      // Choose marker color based on place type
      BitmapDescriptor markerIcon;
      switch (placeType) {
        case PlaceType.hotel:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
        case PlaceType.attraction:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        case PlaceType.foodAndBeverage:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
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
    
    // Fit markers on map
    _zoomToFitMarkers();
  }
  
  void _toggleRouteOptimization() async {
    if (_isRouteOptimized) {
      // If already optimized, revert to normal view
      setState(() {
        _isRouteOptimized = false;
        _routingResult = null;
        _polylines = {};
      });
      // Use regular markers for normal view
      await _updateMapWithNumberedMarkers(_places, optimized: false);
    } else {
      // Optimize the route
      await _fetchPlacesAndCalculateRoute();
      setState(() {
        _isRouteOptimized = true;
      });
    }
  }

  void _changeTransportMode(String mode) {
    if (_selectedTransportMode == mode) return;
    
    setState(() {
      _selectedTransportMode = mode;
      _isLoading = true;
    });
    
    _fetchPlacesAndCalculateRoute();
  }

  Future<void> _fetchPlacesAndCalculateRoute() async {
    setState(() {
      _isLoading = true;
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
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Calculate the optimal route - now async
      final result = await SmartRoutingUtil.calculateOptimalRoute(places, transportMode: _selectedTransportMode);
      
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
      await _updateMapWithNumberedMarkers(result.optimizedRoute, optimized: true);
      
      setState(() {
        _isLoading = false;
      });
      
      // Zoom to fit all markers
      _zoomToFitMarkers();
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _updateRoutePolyline(SmartRoutingResult result) {
    // Set polyline color based on transport mode
    Color polylineColor;
    switch (_selectedTransportMode) {
      case 'driving':
        polylineColor = Colors.blue.shade700;
      case 'walking':
        polylineColor = Colors.green.shade700;
      case 'bicycling':
        polylineColor = Colors.orange.shade700;
      default:
        polylineColor = Colors.blue.shade700;
    }
    
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

  void _updateMapData(SmartRoutingResult result) {
    // Clear existing markers and polylines
    _markers = {};
    _polylines = {};
    
    // Add markers for each place in the optimized route
    for (var i = 0; i < result.optimizedRoute.length; i++) {
      final place = result.optimizedRoute[i];
      final placeType = SmartRoutingUtil.getPlaceType(place);
      
      // Choose marker color based on place type
      BitmapDescriptor markerIcon;
      switch (placeType) {
        case PlaceType.hotel:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
        case PlaceType.attraction:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        case PlaceType.foodAndBeverage:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      }
      
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
    }
    
    // Set polyline color based on transport mode
    Color polylineColor;
    switch (_selectedTransportMode) {
      case 'driving':
        polylineColor = Colors.blue.shade700;
      case 'walking':
        polylineColor = Colors.green.shade700;
      case 'bicycling':
        polylineColor = Colors.orange.shade700;
      default:
        polylineColor = Colors.blue.shade700;
    }
    
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
      
      _polylines.add(polyline);
    }
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
      zoom: 16.0,  // Zoom in closer to see the place details
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
  Widget _buildPlaceListItem(int index, Place place, PlaceType placeType, Color typeColor) {
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
        trailing: isSelected 
            ? Icon(Icons.location_on, color: typeColor)
            : null,
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
  Future<BitmapDescriptor> _createNumberedMarker(int number, Color color) async {
    // Create a picture recorder
    final pictureRecorder = ui.PictureRecorder();
    final canvas = ui.Canvas(pictureRecorder);
    const size = 200.0; // Larger size for better quality
    
    // Calculate center for drawing
    const center = size / 2;
    
    // Draw the standard pin marker (teardrop shape)
    final path = Path()
      ..moveTo(center, size * 0.20) // Top of the pin 
      ..quadraticBezierTo(size * 0.70, size * 0.15, size * 0.70, size * 0.40) // Top right curve
      ..quadraticBezierTo(size * 0.70, size * 0.70, center, size * 0.90) // Bottom right curve
      ..quadraticBezierTo(size * 0.30, size * 0.70, size * 0.30, size * 0.40) // Bottom left curve
      ..quadraticBezierTo(size * 0.30, size * 0.15, center, size * 0.20); // Top left curve
    
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
      Offset(
        center - textPainter.width / 2, 
        size * 0.40 - textPainter.height / 2  // Position centered in the pin
      )
    );
    
    // Convert to image
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      // Fall back to default markers if custom creation fails
      return BitmapDescriptor.defaultMarkerWithHue(
        color == Colors.blue 
          ? BitmapDescriptor.hueBlue
          : color == Colors.red
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueViolet
      );
    }
    
    final bytes = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
  }
  
  // Adding a method to use custom icons (for both optimized and unoptimized views)
  Future<void> _updateMapWithNumberedMarkers(List<Place> places, {bool optimized = false}) async {
    // Clear existing markers
    _markers = {};
    
    // Add markers for each place
    for (var i = 0; i < places.length; i++) {
      final place = places[i];
      final placeType = SmartRoutingUtil.getPlaceType(place);
      
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
            markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
          case PlaceType.attraction:
            markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
          case PlaceType.foodAndBeverage:
            markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
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
    
    // Fit markers on map
    _zoomToFitMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trip Route Map',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlaces,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleRouteOptimization,
        backgroundColor: const Color(0xFF0D3E4C),
        icon: Icon(
          _isRouteOptimized ? Icons.shuffle_on : Icons.shuffle,
          color: Colors.white,
        ),
        label: Text(
          _isRouteOptimized ? 'Disable Optimization' : 'Optimize Route',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(11.5564, 104.9282), // Default to Cambodia coordinates
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
            myLocationButtonEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: true,
            trafficEnabled: _selectedTransportMode == 'driving', // Show traffic when driving
          ),
          
          // Transport mode selector
          if (_isRouteOptimized)
            Positioned(
              top: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Column(
                    children: _transportModes.map((mode) => 
                      IconButton(
                        icon: Icon(
                          mode['icon'], 
                          color: _selectedTransportMode == mode['mode'] 
                              ? Theme.of(context).primaryColor 
                              : Colors.grey,
                        ),
                        tooltip: mode['label'],
                        onPressed: () => _changeTransportMode(mode['mode']),
                      )
                    ).toList(),
                  ),
                ),
              ),
            ),
            
          // Warning banner for direct routing
          if (_isDirectFallbackRoute && !_isLoading && _isRouteOptimized)
            Positioned(
              top: 16,
              left: 16,
              right: 90,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Using direct route - may cross water. Try a different transport mode.',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isCardCollapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
                        height: _isCardCollapsed ? 48 : null,
                        curve: Curves.easeInOut,
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                              bottom: Radius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(_isCardCollapsed ? 12.0 : 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Optimal Route',
                                          style: _isCardCollapsed 
                                              ? Theme.of(context).textTheme.titleMedium
                                              : Theme.of(context).textTheme.titleLarge,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (_isCardCollapsed) 
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4.0),
                                            child: Icon(
                                              Icons.expand_more,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (!_isCardCollapsed)
                                      Text(
                                        'Total: ${_routingResult!.totalDistance.toStringAsFixed(2)} km',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    if (_isCardCollapsed)
                                      Text(
                                        '${_routingResult!.optimizedRoute.length} places - ${_routingResult!.totalDistance.toStringAsFixed(2)} km',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                
                                if (!_isCardCollapsed) ...[
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                      itemCount: _routingResult!.optimizedRoute.length,
                                      itemBuilder: (context, index) {
                                        final place = _routingResult!.optimizedRoute[index];
                                        final placeType = SmartRoutingUtil.getPlaceType(place);
                                        
                                        return _buildPlaceListItem(index, place, placeType, _getPlaceTypeColor(placeType));
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