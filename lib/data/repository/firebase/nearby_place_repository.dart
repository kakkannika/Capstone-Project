import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/data/repository/firebase/place_firebase_repository.dart';
import 'dart:math';
import 'package:tourism_app/models/place/place.dart';

extension PlaceRepositoryExtension on PlaceFirebaseRepository {
  // Calculate distance between two GeoPoints in kilometers using Haversine formula
  double _calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    // Convert latitude and longitude from degrees to radians
    final lat1 = point1.latitude * (pi / 180);
    final lon1 = point1.longitude * (pi / 180);
    final lat2 = point2.latitude * (pi / 180);
    final lon2 = point2.longitude * (pi / 180);
    
    // Haversine formula
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(lat1) * cos(lat2) * 
              sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  // Get places near a specific place within a given radius (in km)
  Future<List<Place>> findNearbyPlaces(String placeId, double radiusInKm) async {
    try {
      // Get the reference place
      final Place? referencePlace = await getPlaceById(placeId);
      if (referencePlace == null) {
        throw Exception('Reference place not found');
      }
      
      // Get all places
      final List<Place> allPlaces = await fetchAllPlaces();
      
      // Filter places within the radius
      final List<Place> nearbyPlaces = allPlaces
          .where((place) {
            // Skip the reference place itself
            if (place.id == placeId) return false;
            
            // Calculate distance
            double distance = _calculateDistance(
              referencePlace.location, 
              place.location
            );
            
            // Check if within radius
            return distance <= radiusInKm;
          })
          .toList();
      
      // Sort by distance
      nearbyPlaces.sort((a, b) {
        double distanceA = _calculateDistance(referencePlace.location, a.location);
        double distanceB = _calculateDistance(referencePlace.location, b.location);
        return distanceA.compareTo(distanceB);
      });
      
      return nearbyPlaces;
    } catch (e) {
      throw Exception('Error finding nearby places: $e');
    }
  }
  
  // Find places within a specific radius from a given location
  Future<List<Place>> findPlacesNearLocation(GeoPoint location, double radiusInKm) async {
    try {
      // Get all places
      final List<Place> allPlaces = await fetchAllPlaces();
      
      // Filter and sort places by distance
      final List<Place> nearbyPlaces = allPlaces
          .where((place) {
            double distance = _calculateDistance(location, place.location);
            return distance <= radiusInKm;
          })
          .toList();
      
      // Sort by distance from the given location
      nearbyPlaces.sort((a, b) {
        double distanceA = _calculateDistance(location, a.location);
        double distanceB = _calculateDistance(location, b.location);
        return distanceA.compareTo(distanceB);
      });
      
      return nearbyPlaces;
    } catch (e) {
      throw Exception('Error finding places near location: $e');
    }
  }
  
  // Get a mapping of places with their distances from each other
  Future<Map<String, Map<String, double>>> getPlaceDistanceMatrix(List<String> placeIds) async {
    try {
      final Map<String, Map<String, double>> distanceMatrix = {};
      final List<Place> places = [];
      
      // Fetch all places by IDs
      for (String id in placeIds) {
        final place = await getPlaceById(id);
        if (place != null) {
          places.add(place);
        }
      }
      
      // Calculate distances between each pair of places
      for (var place1 in places) {
        distanceMatrix[place1.id] = {};
        
        for (var place2 in places) {
          if (place1.id != place2.id) {
            double distance = _calculateDistance(place1.location, place2.location);
            distanceMatrix[place1.id]![place2.id] = distance;
          }
        }
      }
      
      return distanceMatrix;
    } catch (e) {
      throw Exception('Error creating distance matrix: $e');
    }
  }
}