import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism_app/domain/models/user/user_model.dart';
import 'package:tourism_app/domain/models/user/user_preference.dart';


class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> fetchCurrentUser() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        // Create a new user document if it doesn't exist
        final newUser = AppUser(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          preferences: UserPreferences(
            darkMode: false,
            currency: 'USD',
            dailyActivityLimit: 5,
          ),
          role: UserRole.user, // Default role is user
        );

        final userData = {
          'email': newUser.email,
          'displayName': newUser.displayName,
          'photoUrl': newUser.photoUrl,
          'createdAt': Timestamp.fromDate(newUser.createdAt),
          'preferences': newUser.preferences.toMap(),
          'role': UserRole.values.indexOf(newUser.role!),
        };

        await _firestore.collection('users').doc(user.uid).set(userData);

        _currentUser = newUser;
        return newUser;
      }

      try {
        _currentUser = AppUser.fromFirestore(doc);
        print('User role: ${_currentUser?.role}'); // Debug print
        return _currentUser;
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<bool> isUserAdmin() async {
    try {
      final user = await fetchCurrentUser();
      return user?.role == UserRole.admin;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  Future<void> createAdminUser({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      // First create the user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      final newUser = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        preferences: UserPreferences(
          darkMode: false,
          currency: 'USD',
          dailyActivityLimit: 5,
        ),
        role: role,
      );

      final userData = newUser.toMap();
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);
      notifyListeners();
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<void> createNewUser({
    required String uid,
    required String email,
    String? displayName,
    UserRole role = UserRole.user, // Default role is user
  }) async {
    final user = AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      preferences: UserPreferences(), // Default preferences
      role: role,
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());
    _currentUser = user;
    notifyListeners();
  }

  Future<void> updateUserRole(String uid, UserRole newRole) async {
    await _firestore.collection('users').doc(uid).update({
      'role': newRole.index,
    });

    if (_currentUser?.uid == uid) {
      _currentUser = _currentUser?.copyWith(role: newRole);
      notifyListeners();
    }
  }
}