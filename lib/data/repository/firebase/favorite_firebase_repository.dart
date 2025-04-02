// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/data/repository/favorite_repository.dart';
import 'package:tourism_app/data/repository/firebase/place_firebase_repository.dart';
import 'package:tourism_app/data/repository/place_repository.dart';

class FavoriteFirebaseRepository extends FavoriteRepository {
  final PlaceRepository _placeRepository = PlaceFirebaseRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  PlaceRepository get places => _placeRepository;

  @override
  Future<List<String>> loadFavorites(String userId) async {
    final List<String> favoritePlaceIds = [];

    try {
      final docSnapshot =
          await _firestore.collection('favorites').doc(userId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final List<dynamic>? favoriteIds = data?['placeIds'] as List<dynamic>?;

        if (favoriteIds != null) {
          favoritePlaceIds.addAll(favoriteIds.cast<String>());
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final String storageKey = 'favorites_$userId';
        final List<String>? localFavoriteIds = prefs.getStringList(storageKey);

        if (localFavoriteIds != null && localFavoriteIds.isNotEmpty) {
          favoritePlaceIds.addAll(localFavoriteIds);
          await saveFavorites(userId, favoritePlaceIds);
        }
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }

    return favoritePlaceIds;
  }

  @override
  Future<void> saveFavorites(
      String userId, List<String> favoritePlaceIds) async {
    try {
      await _firestore.collection('favorites').doc(userId).set({
        'placeIds': favoritePlaceIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      final String storageKey = 'favorites_$userId';
      await prefs.setStringList(storageKey, favoritePlaceIds);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  @override
  Future<List<Place>> fetchFavoritePlaces(List<String> favoritePlaceIds) async {
    final List<Place> places = [];

    try {
      for (final id in favoritePlaceIds) {
        final place = await _placeRepository.getPlaceById(id);
        if (place != null) {
          places.add(place);
        }
      }
    } catch (e) {
      print('Error fetching favorite places: $e');
    }

    return places;
  }
}
