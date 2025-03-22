import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/repository/firebase/place_firebase_repository.dart';
import 'package:tourism_app/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:isolate';

class FavoriteProvider extends ChangeNotifier {
  final PlaceFirebaseRepository _placeRepository = PlaceFirebaseRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  FavoriteProvider() {
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

  // Collection reference for favorites in Firestore
  CollectionReference get _favoritesCollection => _firestore.collection('favorites');

  // Document reference for current user's favorites
  DocumentReference? get _userFavoritesDoc {
    if (_userId == null) return null;
    return _favoritesCollection.doc(_userId);
  }

  // Load favorites from Firestore
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
      // First try to get from Firestore (for cross-device sync)
      final docSnapshot = await _userFavoritesDoc?.get();
      
      _favoritePlaceIds.clear();
      if (docSnapshot != null && docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        final List<dynamic>? favoriteIds = data?['placeIds'] as List<dynamic>?;
        
        if (favoriteIds != null) {
          _favoritePlaceIds.addAll(favoriteIds.cast<String>());
        }
      } else {
        // If not in Firestore yet, try to get from local storage as fallback
        final prefs = await SharedPreferences.getInstance();
        final String storageKey = 'favorites_${_userId ?? "guest"}';
        final List<String>? localFavoriteIds = prefs.getStringList(storageKey);
        
        if (localFavoriteIds != null && localFavoriteIds.isNotEmpty) {
          _favoritePlaceIds.addAll(localFavoriteIds);
          // Sync local favorites to Firestore without waiting
          _triggerFirestoreSave();
        }
      }
      
      // Update local cache
      _updateLocalCache();
      
      await _fetchFavoritePlaces();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
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

  // Trigger background save without blocking UI
  void _triggerFirestoreSave() {
    // Only run if not already in progress
    if (_pendingOperations.contains('save')) return;
    
    _pendingOperations.add('save');
    
    // Use a microtask to ensure current UI work completes first
    Future.microtask(() async {
      try {
        // Capture current state to avoid race conditions
        final List<String> idsToSave = List.from(_favoritePlaceIds);
        final String? userIdToUse = _userId;
        
        if (userIdToUse == null) return;
        
        // Save to Firestore directly, but in a microtask to avoid blocking UI
        await _firestore.collection('favorites').doc(userIdToUse).set({
          'placeIds': idsToSave,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        print('✅ Favorites saved to Firestore for user: $userIdToUse');
        print('✅ Saved favorite IDs: $idsToSave');
        
        // Also save to SharedPreferences in background
        await _saveToSharedPreferences(idsToSave, userIdToUse);
      } catch (e) {
        print('❌ Error saving favorites to Firestore: $e');
        debugPrint('Background save error: $e');
      } finally {
        _pendingOperations.remove('save');
      }
    });
  }
  
  // This method is no longer needed as we're doing direct Firestore calls
  // but keep it for reference
  static Future<void> _saveToFirestore(Map<String, dynamic> params) async {
    final List<String> ids = params['userIds'] as List<String>;
    final String userId = params['userId'] as String;
    
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('favorites').doc(userId).set({
        'placeIds': ids,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Favorites saved to Firestore via compute for user: $userId');
    } catch (e) {
      print('❌ Error in compute Firestore save: $e');
      debugPrint('Error in background Firestore save: $e');
    }
  }
  
  // Save to SharedPreferences without blocking UI
  Future<void> _saveToSharedPreferences(List<String> ids, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String storageKey = 'favorites_$userId';
      await prefs.setStringList(storageKey, ids);
      print('✅ Favorites saved to SharedPreferences for user: $userId');
    } catch (e) {
      print('❌ Error saving to SharedPreferences: $e');
      debugPrint('Error saving to SharedPreferences: $e');
    }
  }

  // Fetch all favorite places
  Future<void> _fetchFavoritePlaces() async {
    if (_favoritePlaceIds.isEmpty) {
      _favoritePlaces = [];
      notifyListeners();
      return;
    }

    try {
      final List<Place> places = [];
      
      for (final id in _favoritePlaceIds) {
        final place = await _placeRepository.getPlaceById(id);
        if (place != null) {
          places.add(place);
        }
      }
      
      _favoritePlaces = places;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching favorite places: $e');
    }
  }

  // Toggle favorite status - completely non-blocking operation
  void toggleFavorite(String placeId) {
    // 1. Update local cache immediately (used by UI)
    final bool newState = !_localFavoriteCache.containsKey(placeId) || !_localFavoriteCache[placeId]!;
    _localFavoriteCache[placeId] = newState;
    
    print('🔄 Toggling favorite for place: $placeId to state: $newState');
    
    // 2. Update internal lists
    if (newState) {
      if (!_favoritePlaceIds.contains(placeId)) {
        _favoritePlaceIds.add(placeId);
        print('➕ Added $placeId to favorites list');
      }
    } else {
      _favoritePlaceIds.remove(placeId);
      _favoritePlaces.removeWhere((place) => place.id == placeId);
      print('➖ Removed $placeId from favorites list');
    }
    
    // 3. Notify UI immediately - minimal work at this point
    notifyListeners();
    
    // 4. Schedule background tasks completely detached from UI thread
    print('🔄 Triggering Firestore save for user: $_userId');
    _triggerFirestoreSave();
    
    // 5. Load place data in background if needed
    if (newState && !_favoritePlaces.any((place) => place.id == placeId)) {
      _triggerPlaceLoad(placeId);
    }
  }

  // Trigger background place load without blocking UI
  void _triggerPlaceLoad(String placeId) {
    // Skip if already loading this place
    if (_pendingOperations.contains('load_$placeId')) return;
    
    _pendingOperations.add('load_$placeId');
    
    Future.microtask(() async {
      try {
        final place = await _placeRepository.getPlaceById(placeId);
        if (place != null) {
          _favoritePlaces.add(place);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error loading place in background: $e');
      } finally {
        _pendingOperations.remove('load_$placeId');
      }
    });
  }

  // Check if a place is favorite - ultra fast using local cache
  bool isFavorite(String placeId) {
    return _localFavoriteCache.containsKey(placeId) && _localFavoriteCache[placeId]!;
  }
} 