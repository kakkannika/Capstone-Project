import 'dart:math';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// Define an enum for place types with priority order
enum PlaceType {
  hotel,       // First priority
  attraction,  // Second priority
  foodAndBeverage, // Third priority
}

class RouteNode implements Comparable<RouteNode> {
  final Place? currentPlace;
  final double totalDistance;
  final List<Place> path;
  final List<Place> remainingHotels;
  final List<Place> remainingAttractions;
  final List<Place> remainingFnB;
  final PlaceType? lastVisitedType;

  RouteNode({
    this.currentPlace,
    required this.totalDistance,
    required this.path,
    required this.remainingHotels,
    required this.remainingAttractions,
    required this.remainingFnB,
    this.lastVisitedType,
  });

  @override
  int compareTo(RouteNode other) {
    return totalDistance.compareTo(other.totalDistance);
  }

  RouteNode copyWith({
    Place? currentPlace,
    double? totalDistance,
    List<Place>? path,
    List<Place>? remainingHotels,
    List<Place>? remainingAttractions,
    List<Place>? remainingFnB,
    PlaceType? lastVisitedType,
  }) {
    return RouteNode(
      currentPlace: currentPlace ?? this.currentPlace,
      totalDistance: totalDistance ?? this.totalDistance,
      path: path ?? List.from(this.path),
      remainingHotels: remainingHotels ?? List.from(this.remainingHotels),
      remainingAttractions: remainingAttractions ?? List.from(this.remainingAttractions),
      remainingFnB: remainingFnB ?? List.from(this.remainingFnB),
      lastVisitedType: lastVisitedType ?? this.lastVisitedType,
    );
  }
}

class SmartRoutingResult {
  final List<Place> optimizedRoute;
  final double totalDistance;
  final List<LatLng> polylinePoints;

  SmartRoutingResult({
    required this.optimizedRoute,
    required this.totalDistance,
    required this.polylinePoints,
  });
}

class SmartRoutingUtil {
  // Google Maps API key - get from your configuration
  static String get _apiKey {
    // Use actual API key provided by user
    return 'AIzaSyBAeKngtUoBtDDR6wSAV2SDn27YJIyeZ9o';
  }
  static final Dio _dio = Dio();

  /// Determines the type of place
  static PlaceType getPlaceType(Place place) {
    final hotelCategories = [
      'hotel', 
      'hostel',
      'resort',
      'accommodation',
      'guesthouse',
      'lodging',
    ];
    
    final fnbCategories = [
      'restaurant', 
      'cafe', 
      'food', 
      'dining', 
      'bar', 
      'pub',
      'food and beverage',
      'f&b',
      'eatery',
    ];
    
    final category = place.category.toLowerCase();
    
    if (hotelCategories.any((c) => category.contains(c))) {
      return PlaceType.hotel;
    } else if (fnbCategories.any((c) => category.contains(c))) {
      return PlaceType.foodAndBeverage;
    } else {
      return PlaceType.attraction;
    }
  }

  static bool isHotel(Place place) {
    return getPlaceType(place) == PlaceType.hotel;
  }

  static bool isFoodAndBeverage(Place place) {
    return getPlaceType(place) == PlaceType.foodAndBeverage;
  }

  static bool isAttraction(Place place) {
    return getPlaceType(place) == PlaceType.attraction;
  }

  /// Calculate distance between two GeoPoints in kilometers using Haversine formula
  static double calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    // Convert latitude and longitude from degrees to radians
    final double lat1 = point1.latitude * pi / 180;
    final double lon1 = point1.longitude * pi / 180;
    final double lat2 = point2.latitude * pi / 180;
    final double lon2 = point2.longitude * pi / 180;
    
    // Haversine formula
    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;
    final double a = sin(dLat / 2) * sin(dLat / 2) + 
                     cos(lat1) * cos(lat2) * 
                     sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Decode Google polyline
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;
      points.add(LatLng(latitude, longitude));
    }
    return points;
  }

  /// Get directions from Google Directions API with improved options
  static Future<Map<String, dynamic>> getDirections(
    GeoPoint origin, 
    GeoPoint destination,
    {String transportMode = 'driving'}
  ) async {
    try {
      final String url = 'https://maps.googleapis.com/maps/api/directions/json';
      
      debugPrint('Requesting directions from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude} via $transportMode');
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': transportMode, // driving, walking, bicycling, transit
          'alternatives': 'true', // Get alternative routes
          'avoid': 'ferries,indoor', // Avoid water crossings and indoor paths
          'key': _apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('Directions API response status: ${data['status']}');
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          // Extract polyline and distance from the first route
          final route = data['routes'][0];
          final leg = route['legs'][0];
          final distance = leg['distance']['value'] / 1000; // Convert meters to kilometers
          final encodedPolyline = route['overview_polyline']['points'];
          final polylinePoints = decodePolyline(encodedPolyline);
          
          // Check if polyline is valid (has more than 2 points - not just start and end)
          if (polylinePoints.length > 2) {
            return {
              'distance': distance,
              'polylinePoints': polylinePoints,
            };
          } else {
            debugPrint('Route seems too direct, may cross water. Trying with more waypoints.');
          }
        } else {
          debugPrint('No routes found or API error: ${data['status']}');
          
          // If driving failed, try walking as a fallback
          if (transportMode == 'driving') {
            debugPrint('Retrying with walking mode...');
            return getDirections(origin, destination, transportMode: 'walking');
          }
        }
      }
      
      // If we reached here, the route is likely invalid. Try with waypoints.
      return _getDirectionsWithWaypoints(origin, destination, transportMode);
    } catch (e) {
      debugPrint('Error getting directions: $e');
      return _getDirectionsWithWaypoints(origin, destination, transportMode);
    }
  }
  
  /// Get directions with intermediate waypoints to avoid water
  static Future<Map<String, dynamic>> _getDirectionsWithWaypoints(
    GeoPoint origin, 
    GeoPoint destination,
    String transportMode
  ) async {
    try {
      // Calculate a midpoint slightly offset to force the route to go around water
      final midLat = (origin.latitude + destination.latitude) / 2;
      final midLng = (origin.longitude + destination.longitude) / 2;
      
      // Add a slight offset to the midpoint to push route on land (west for Cambodia)
      // Determine direction - whether to go east or west of the water
      // For Cambodia, we want to go west (negative longitude offset)
      final waypointLng = midLng - 0.003; // Push west by ~300m
      
      final waypoint = '$midLat,$waypointLng'; 
      
      final String url = 'https://maps.googleapis.com/maps/api/directions/json';
      
      debugPrint('Trying with waypoints to avoid water crossing');
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'waypoints': 'via:$waypoint',
          'mode': transportMode,
          'alternatives': 'true',
          'avoid': 'ferries,indoor',
          'key': _apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          final distance = leg['distance']['value'] / 1000;
          final encodedPolyline = route['overview_polyline']['points'];
          final polylinePoints = decodePolyline(encodedPolyline);
          
          return {
            'distance': distance,
            'polylinePoints': polylinePoints,
          };
        }
      }
      
      // Final fallback: try with more advanced waypoints
      return _getFallbackWithRoadWaypoints(origin, destination, transportMode);
    } catch (e) {
      debugPrint('Error with waypoint directions: $e');
      return _getFallbackWithRoadWaypoints(origin, destination, transportMode);
    }
  }
  
  /// Get a more complex fallback route with multiple waypoints
  static Future<Map<String, dynamic>> _getFallbackWithRoadWaypoints(
    GeoPoint origin, 
    GeoPoint destination,
    String transportMode
  ) async {
    try {
      // Calculate multiple waypoints around the water
      final double distLat = destination.latitude - origin.latitude;
      final double distLng = destination.longitude - origin.longitude;
      
      // Create 3 waypoints at 25%, 50% and 75% of the route
      final List<String> waypoints = [];
      for (int i = 1; i <= 3; i++) {
        final fraction = i / 4;
        final waypointLat = origin.latitude + distLat * fraction;
        // Push the waypoint more inland (west in this case for Cambodia)
        final waypointLng = origin.longitude + distLng * fraction - 0.005;
        waypoints.add('$waypointLat,$waypointLng');
      }
      
      final String waypointString = waypoints.map((w) => 'via:$w').join('|');
      
      final String url = 'https://maps.googleapis.com/maps/api/directions/json';
      
      debugPrint('Trying with multiple waypoints for better road routing');
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'waypoints': waypointString,
          'mode': transportMode,
          'alternatives': 'true',
          'avoid': 'ferries,indoor',
          'key': _apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final legs = route['legs'] as List;
          double totalDistance = 0;
          for (final leg in legs) {
            totalDistance += leg['distance']['value'] / 1000;
          }
          
          final encodedPolyline = route['overview_polyline']['points'];
          final polylinePoints = decodePolyline(encodedPolyline);
          
          return {
            'distance': totalDistance,
            'polylinePoints': polylinePoints,
          };
        }
      }
      
      // If all else fails, just return a direct line
      debugPrint('All routing methods failed, falling back to basic line');
      return _getFallbackDirections(origin, destination);
    } catch (e) {
      debugPrint('Error with advanced waypoint directions: $e');
      return _getFallbackDirections(origin, destination);
    }
  }
  
  /// Fallback method to get a straight line when API fails
  static Map<String, dynamic> _getFallbackDirections(GeoPoint origin, GeoPoint destination) {
    // Calculate intermediate points to make the line look more natural
    final directDistance = calculateDistance(origin, destination);
    final numPoints = max(2, (directDistance / 0.1).round()); // One point every ~100m
    
    List<LatLng> points = [];
    
    for (int i = 0; i < numPoints; i++) {
      final fraction = i / (numPoints - 1);
      final lat = origin.latitude + (destination.latitude - origin.latitude) * fraction;
      final lng = origin.longitude + (destination.longitude - origin.longitude) * fraction;
      points.add(LatLng(lat, lng));
    }
    
    return {
      'distance': directDistance,
      'polylinePoints': points,
    };
  }

  /// Calculate the optimal route for visiting places in a day with new order:
  /// Hotel -> Attraction -> F&B -> Attraction -> F&B ...
  static Future<SmartRoutingResult> calculateOptimalRoute(
    List<Place> places, 
    {String transportMode = 'driving'}
  ) async {
    if (places.isEmpty) {
      return SmartRoutingResult(
        optimizedRoute: [],
        totalDistance: 0,
        polylinePoints: [],
      );
    }
    
    if (places.length == 1) {
      return SmartRoutingResult(
        optimizedRoute: places,
        totalDistance: 0,
        polylinePoints: [LatLng(places[0].location.latitude, places[0].location.longitude)],
      );
    }
    
    // Categorize places
    final List<Place> hotels = [];
    final List<Place> attractions = [];
    final List<Place> fnbPlaces = [];
    
    for (final place in places) {
      final placeType = getPlaceType(place);
      switch (placeType) {
        case PlaceType.hotel:
          hotels.add(place);
        case PlaceType.attraction:
          attractions.add(place);
        case PlaceType.foodAndBeverage:
          fnbPlaces.add(place);
      }
    }
    
    // Start with the optimized sequence based on the requested order
    List<Place> optimizedRoute = [];
    
    // Start with hotels
    optimizedRoute.addAll(hotels);
    
    // If no hotels, start with attractions
    if (optimizedRoute.isEmpty && attractions.isNotEmpty) {
      optimizedRoute.add(attractions.removeAt(0));
    }
    
    // If still empty, just use any place to start
    if (optimizedRoute.isEmpty && fnbPlaces.isNotEmpty) {
      optimizedRoute.add(fnbPlaces.removeAt(0));
    }
    
    // Now alternate between attractions and F&B, respecting the ordering rule
    while (attractions.isNotEmpty || fnbPlaces.isNotEmpty) {
      // After hotel, add an attraction
      if (optimizedRoute.isNotEmpty && isHotel(optimizedRoute.last) && attractions.isNotEmpty) {
        optimizedRoute.add(attractions.removeAt(0));
      }
      // After attraction, add F&B
      else if (optimizedRoute.isNotEmpty && isAttraction(optimizedRoute.last) && fnbPlaces.isNotEmpty) {
        optimizedRoute.add(fnbPlaces.removeAt(0));
      }
      // After F&B, add attraction
      else if (optimizedRoute.isNotEmpty && isFoodAndBeverage(optimizedRoute.last) && attractions.isNotEmpty) {
        optimizedRoute.add(attractions.removeAt(0));
      }
      // If can't follow the rule, just add any remaining places
      else if (attractions.isNotEmpty) {
        optimizedRoute.add(attractions.removeAt(0));
      }
      else if (fnbPlaces.isNotEmpty) {
        optimizedRoute.add(fnbPlaces.removeAt(0));
      }
    }
    
    // Now optimize the path for shortest distances using Google Directions API
    List<LatLng> fullPolyline = [];
    double totalDistance = 0;
    
    // Case for just 2 locations - direct path
    if (optimizedRoute.length == 2) {
      final directions = await getDirections(
        optimizedRoute[0].location, 
        optimizedRoute[1].location,
        transportMode: transportMode
      );
      
      return SmartRoutingResult(
        optimizedRoute: optimizedRoute,
        totalDistance: directions['distance'],
        polylinePoints: directions['polylinePoints'],
      );
    }
    
    // Case for 3+ locations - use intermediate waypoints for better routes
    for (int i = 0; i < optimizedRoute.length - 1; i++) {
      try {
        final current = optimizedRoute[i];
        final next = optimizedRoute[i + 1];
        
        // If we're detecting unusual routes (like crossing water), we might add intermediate waypoints
        // Simplest approach is to just get directions for each segment
        final directions = await getDirections(
          current.location, 
          next.location,
          transportMode: transportMode
        );
        totalDistance += directions['distance'];
        
        // Add polyline points, avoiding duplications
        if (i == 0) {
          fullPolyline.addAll(directions['polylinePoints']);
        } else if (directions['polylinePoints'].isNotEmpty) {
          // Skip the first point to avoid duplication - it should match the end of the previous segment
          fullPolyline.addAll(directions['polylinePoints'].skip(1));
        }
      } catch (e) {
        debugPrint('Error calculating segment ${i}: $e');
        // Continue to next segment even if this one fails
      }
    }
    
    return SmartRoutingResult(
      optimizedRoute: optimizedRoute,
      totalDistance: totalDistance,
      polylinePoints: fullPolyline,
    );
  }
} 