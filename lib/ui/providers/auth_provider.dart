// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tourism_app/models/user/user_model.dart';
import 'package:tourism_app/models/user/user_preference.dart';
import 'package:tourism_app/data/repository/authentication_repository.dart';
import 'package:tourism_app/data/repository/firebase/auth_firebase_repository.dart';
import 'package:tourism_app/utils/profile_cache.dart';


class AuthServiceProvider extends ChangeNotifier {
  final AuthenticationRepository _authRepository = AuthFirebaseRepository();

  // User state
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  // Authentication status
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Authentication state
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Default constructor
  AuthServiceProvider();
  
  // Factory constructor that initializes without notification
  static Future<AuthServiceProvider> createInitialized() async {
    final provider = AuthServiceProvider();
    await provider.initializeAuth(silent: true);
    return provider;
  }

  // Initialize authentication state - check if user is already logged in
  Future<bool> initializeAuth({bool silent = false}) async {
    // Set loading immediately, but don't notify yet
    _isLoading = true;
    
    try {
      // Check if there's a current Firebase user
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      
      if (firebaseUser != null && firebaseUser.emailVerified) {
        // User is logged in and verified, fetch user data
        DocumentSnapshot userDoc = await _authRepository.getUserData(firebaseUser.uid);
        
        if (userDoc.exists) {
          _currentUser = AppUser.fromFirestore(userDoc);
          
          // Save user data to local cache
          await ProfileCache.saveUserData(_currentUser!.toMap());
          
          _isAuthenticated = true;
        } else {
          // Check if we have cached user data
          final cachedUserData = await ProfileCache.getUserData();
          if (cachedUserData != null) {
            try {
              _currentUser = AppUser.fromMap(cachedUserData);
              _isAuthenticated = true;
            } catch (e) {
              await _authRepository.signOut();
              _isAuthenticated = false;
              await ProfileCache.clearCache();
            }
          } else {
            // User exists in Firebase Auth but not in Firestore
            await _authRepository.signOut();
            _isAuthenticated = false;
          }
        }
      } else {
        _isAuthenticated = false;
        
        // Clear local cache when not authenticated
        await ProfileCache.clearCache();
      }
    } catch (e) {
      _handleError('Error initializing auth: $e', notify: false);
      _isAuthenticated = false;
    }
    
    // Update final state
    _isLoading = false;
    _isInitialized = true;
    
    // Only notify once at the end
    if (!silent) {
      notifyListeners();
    }
    return _isAuthenticated;
  }

  // Signup method with Firestore integration
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
    BuildContext? context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (password != confirmPassword) {
      _handleError('Passwords do not match');
      return false;
    }

    try {
      UserCredential userCredential = await _authRepository.signUpWithEmail(email, password);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        AppUser newUser = AppUser(
          uid: firebaseUser.uid,
          email: email,
          displayName: username,
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          preferences: UserPreferences(), // Default preferences
        );

        await _authRepository.saveUserToFirestore(newUser);

        // Send email verification
        await _authRepository.sendEmailVerification(firebaseUser);

        _showToast('Verification email sent. Please verify before logging in.');

        await _authRepository.signOut();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign In with Email & Fetch User Data
  Future<bool> signInWithEmail({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _authRepository.signInWithEmail(email, password);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null && firebaseUser.emailVerified) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await _authRepository.getUserData(firebaseUser.uid);

        if (userDoc.exists) {
          _currentUser = AppUser.fromFirestore(userDoc);
          
          // Save user data to local storage
          await ProfileCache.saveUserData(_currentUser!.toMap());
          
          _isAuthenticated = true;
          _showToast('Sign in successful');
          return true;
        } else {
          _handleError('User data not found in Firestore');
          _isAuthenticated = false;
          return false;
        }
      } else {
        _showToast('Please verify your email before logging in.');
        await firebaseUser?.sendEmailVerification();
        await _authRepository.signOut();
        _isAuthenticated = false;
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email, [BuildContext? context]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(email);
      _showToast('Password reset email sent.');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google Sign In with Firestore Integration
  Future<bool> signInWithGoogle([BuildContext? context]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _authRepository.signInWithGoogle();

      if (googleUser == null) {
        _handleError('Google sign in cancelled');
        _isAuthenticated = false;
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await _authRepository.getGoogleAuth(googleUser);
      final AuthCredential credential = _authRepository.getGoogleCredential(googleAuth);

      UserCredential userCredential = await _authRepository.signInWithGoogleCredential(credential);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        DocumentSnapshot userDoc = await _authRepository.getUserData(firebaseUser.uid);

        if (!userDoc.exists) {
          AppUser newUser = AppUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            createdAt: DateTime.now(),
            preferences: UserPreferences(),
          );

          await _authRepository.saveUserToFirestore(newUser);
          _currentUser = newUser;
        } else {
          _currentUser = AppUser.fromFirestore(userDoc);
        }

        _isAuthenticated = true;
        _showToast('Google sign in successful');
        return true;
      }
      return false;
    } catch (e) {
      _handleError('Google Sign-In Error: $e');
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
    UserPreferences? preferences,
    File? profileImage,
  }) async {
    if (_currentUser == null) {
      _handleError('Cannot update profile - no user logged in');
      throw Exception("Cannot update profile - user not authenticated");
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    Map<String, dynamic> updates = {};
    String? finalPhotoUrl = photoUrl;
    
    try {
      // If profile image is provided, upload it first
      if (profileImage != null) {
        try {
          // Save image locally for quick access
          await ProfileCache.saveProfileImage(profileImage);
          
          // Upload image to Firebase Storage
          finalPhotoUrl = await _authRepository.uploadProfileImage(
            profileImage, 
            _currentUser!.uid
          );
          
          // Set the new photo URL
          updates['photoUrl'] = finalPhotoUrl;
        } catch (e) {
          _handleError('Error uploading profile image: $e');
          _isLoading = false;
          notifyListeners();
          throw e;
        }
      } else if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }
      
      // Add other updates if provided
      if (displayName != null) {
        updates['displayName'] = displayName;
      }
      
      if (preferences != null) {
        updates['preferences'] = preferences.toMap();
      }
      
      // Only update Firestore if we have changes to make
      if (updates.isNotEmpty) {
        // Update Firestore
        await _authRepository.updateUserProfile(_currentUser!.uid, updates);
        
        // Update Firebase Auth user profile
        final User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          if (displayName != null) {
            await firebaseUser.updateDisplayName(displayName);
          }
          
          if (finalPhotoUrl != null) {
            await firebaseUser.updatePhotoURL(finalPhotoUrl);
          }
        }
        
        // Update local user model
        _currentUser = AppUser(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          displayName: displayName ?? _currentUser!.displayName,
          photoUrl: finalPhotoUrl ?? _currentUser!.photoUrl,
          createdAt: _currentUser!.createdAt,
          preferences: preferences ?? _currentUser!.preferences,
        );
        
        // Save user data to local cache
        await ProfileCache.saveUserData(_currentUser!.toMap());
      }
    } catch (e) {
      _handleError('Error updating profile: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Out
  Future<bool> signOut([BuildContext? context]) async {
    try {
      _isLoading = true;
      
      // Perform all sign out operations
      await _authRepository.signOutGoogle();
      await _authRepository.signOutFacebook();
      await _authRepository.signOut();
      
      // Clear local cached data
      await ProfileCache.clearCache();
      
      // Update state only after all async operations
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      
      // Notify only once at the end
      notifyListeners();
      
      _showToast('Signed out successfully');
      return true;
    } catch (e) {
      _handleError('Error signing out: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Error Handling
  void _handleAuthError(FirebaseAuthException e, {bool notify = true}) {
    _handleError('Error: ${e.message}', notify: notify);
  }

  void _handleError(String message, {bool notify = true}) {
    _errorMessage = message;
    _showToast(message);
    // Only notify if we're not in the middle of another state change and notification is requested
    if (notify && !_isLoading) {
      notifyListeners();
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM);
  }
}