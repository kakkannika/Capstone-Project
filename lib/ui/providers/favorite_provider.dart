// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism_app/domain/models/place/place.dart';
import 'package:tourism_app/data/repository/favorite_repository.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteRepository _favoriteRepository;

  final List<String> _favoritePlaceIds = [];
  List<Place> _favoritePlaces = [];
  bool _isLoading = false;
  String? _userId;

  // Local state cache to avoid UI freezes
  final Map<String, bool> _localFavoriteCache = {};

  // Set of operations in progress to avoid duplication
  final Set<String> _pendingOperations = {};

  List<String> get favoritePlaceIds => _favoritePlaceIds;
  List<Place> get favoritePlaces => _favoritePlaces;
  bool get isLoading => _isLoading;

  FavoriteProvider(this._favoriteRepository) {
    // Get current user ID on initialization
    _userId = FirebaseAuth.instance.currentUser?.uid;

    // Listen for auth state changes to reload favorites when user changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (_userId != user?.uid) {
        _userId = user?.uid;
        _loadFavorites();
      }
    });

    _loadFavorites();
  }

  // Load favorites from repository
  Future<void> _loadFavorites() async {
    if (_userId == null) {
      // Not logged in, clear favorites
      _favoritePlaceIds.clear();
      _favoritePlaces = [];
      _localFavoriteCache.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _favoritePlaceIds.clear();
      _favoritePlaceIds
          .addAll(await _favoriteRepository.loadFavorites(_userId!));
      _updateLocalCache();
      _favoritePlaces =
          await _favoriteRepository.fetchFavoritePlaces(_favoritePlaceIds);
    } catch (e) {
      print('Error loading favorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update local cache for fast lookups
  void _updateLocalCache() {
    _localFavoriteCache.clear();
    for (final id in _favoritePlaceIds) {
      _localFavoriteCache[id] = true;
    }
  }

  // Toggle favorite status
  void toggleFavorite(String placeId) {
    final bool newState = !_localFavoriteCache.containsKey(placeId) ||
        !_localFavoriteCache[placeId]!;
    _localFavoriteCache[placeId] = newState;

    if (newState) {
      if (!_favoritePlaceIds.contains(placeId)) {
        _favoritePlaceIds.add(placeId);
      }
    } else {
      _favoritePlaceIds.remove(placeId);
      _favoritePlaces.removeWhere((place) => place.id == placeId);
    }

    notifyListeners();
    _triggerSave();
    if (newState && !_favoritePlaces.any((place) => place.id == placeId)) {
      _triggerPlaceLoad(placeId);
    }
  }

  // Trigger save to repository
  void _triggerSave() {
    if (_pendingOperations.contains('save')) return;

    _pendingOperations.add('save');

    Future.microtask(() async {
      try {
        await _favoriteRepository.saveFavorites(_userId!, _favoritePlaceIds);
      } catch (e) {
        print('Error saving favorites: $e');
      } finally {
        _pendingOperations.remove('save');
      }
    });
  }

  // Trigger background place load
  void _triggerPlaceLoad(String placeId) {
    if (_pendingOperations.contains('load_$placeId')) return;

    _pendingOperations.add('load_$placeId');

    Future.microtask(() async {
      try {
        final place = await _favoriteRepository.places.getPlaceById(placeId);
        if (place != null) {
          _favoritePlaces.add(place);
          notifyListeners();
        }
      } catch (e) {
        print('Error loading place: $e');
      } finally {
        _pendingOperations.remove('load_$placeId');
      }
    });
  }

  // Check if a place is favorite
  bool isFavorite(String placeId) {
    return _localFavoriteCache.containsKey(placeId) &&
        _localFavoriteCache[placeId]!;
  }
}
