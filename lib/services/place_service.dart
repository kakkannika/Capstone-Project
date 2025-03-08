import 'package:cloud_firestore/cloud_firestore.dart' hide DocumentSnapshot;
import 'package:tourism_app/models/place_model.dart';

class PlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Fetch all places
  Future<List<Place>> getAllPlaces() async {
    try {
      print('Fetching all places from Firestore...');
      final QuerySnapshot snapshot = await _firestore.collection('places').get();
      print('Got ${snapshot.docs.length} places from Firestore');
      
      final places = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Place data: $data');
        return Place.fromFirestore(
          DocumentSnapshot(doc.id, data),
        );
      }).toList();
      
      print('Successfully converted ${places.length} Firestore documents to Place objects');
      return places;
    } catch (e) {
      print('Error fetching places: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }
  
  // Fetch popular places (sorted by rating)
  Future<List<Place>> getPopularPlaces({int limit = 6}) async {
    try {
      print('Fetching popular places from Firestore...');
      final QuerySnapshot snapshot = await _firestore
          .collection('places')
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();
      
      print('Got ${snapshot.docs.length} popular places from Firestore');
      
      final places = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Popular place data: $data');
        return Place.fromFirestore(
          DocumentSnapshot(doc.id, data),
        );
      }).toList();
      
      print('Successfully converted ${places.length} popular places');
      return places;
    } catch (e) {
      print('Error fetching popular places: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }
  
  // Fetch places by category
  Future<List<Place>> getPlacesByCategory(PlaceCategory category, {int limit = 10}) async {
    try {
      print('Fetching places for category ${category.name}...');
      final QuerySnapshot snapshot = await _firestore
          .collection('places')
          .where('category', isEqualTo: category.index)
          .limit(limit)
          .get();
          
      print('Got ${snapshot.docs.length} places for category ${category.name}');
      return snapshot.docs.map((doc) {
        return Place.fromFirestore( 
          DocumentSnapshot(doc.id, doc.data() as Map<String, dynamic>),
        );
      }).toList();
    } catch (e) {
      print('Error fetching places by category: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }
  
  // Get random places for weekend trips
  Future<List<Place>> getRandomPlaces({int limit = 4}) async {
    try {
      print('Fetching random places...');
      final QuerySnapshot snapshot = await _firestore
          .collection('places')
          .limit(limit * 2)
          .get();
      
      print('Got ${snapshot.docs.length} places for random selection');
      
      final places = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Random place data: $data');
        return Place.fromFirestore(
          DocumentSnapshot(doc.id, data),
        );
      }).toList();
      
      places.shuffle();
      final selectedPlaces = places.take(limit).toList();
      print('Selected ${selectedPlaces.length} random places');
      return selectedPlaces;
    } catch (e) {
      print('Error fetching random places: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }
  
  // Search for places in the main places collection
  Future<List<Place>> searchPlaces(String query) async {
    try {
      // Convert query to lowercase for case-insensitive search
      final queryLower = query.toLowerCase();
      
      // Get all places from the collection
      // Note: In a production app, you would implement server-side search or use Algolia/ElasticSearch
      final placesSnapshot = await _firestore.collection('places').get();
      
      // Filter places client-side based on the query
      final List<Place> results = [];
      
      for (final doc in placesSnapshot.docs) {
        final data = doc.data();
        final name = (data['name'] as String? ?? '').toLowerCase();
        final description = (data['description'] as String? ?? '').toLowerCase();
        
        // Check if the place name or description contains the query
        if (name.contains(queryLower) || description.contains(queryLower)) {
          final docSnapshot = DocumentSnapshot(doc.id, data);
          results.add(Place.fromFirestore(docSnapshot));
        }
      }
      
      return results;
    } catch (e) {
      print('Error searching places: $e');
      rethrow;
    }
  }
  
  // Get place details by ID
  Future<Place?> getPlaceById(String placeId) async {
    try {
      final doc = await _firestore.collection('places').doc(placeId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      final docSnapshot = DocumentSnapshot(doc.id, doc.data() ?? {});
      return Place.fromFirestore(docSnapshot);
    } catch (e) {
      print('Error getting place by ID: $e');
      rethrow;
    }
  }
  
  // Get recommended places based on category or popularity
  Future<List<Place>> getRecommendedPlaces({int limit = 10}) async {
    try {
      final placesSnapshot = await _firestore
          .collection('places')
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();
      
      final List<Place> recommendedPlaces = [];
      
      for (final doc in placesSnapshot.docs) {
        final docSnapshot = DocumentSnapshot(doc.id, doc.data());
        recommendedPlaces.add(Place.fromFirestore(docSnapshot));
      }
      
      return recommendedPlaces;
    } catch (e) {
      print('Error getting recommended places: $e');
      rethrow;
    }
  }
} 