// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add this import
import 'package:tourism_app/models/user/user_model.dart';
import 'package:tourism_app/models/user/user_preference.dart';
import 'package:tourism_app/data/repository/authentication_repository.dart';
import 'package:tourism_app/data/repository/firebase/auth_firebase_repository.dart';
import 'package:tourism_app/ui/screens/auth/login_screen.dart';
import 'package:tourism_app/ui/screens/home/home_page.dart';

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

  Future<bool> initializeAuth() async {
    try {
      // Get the current Firebase user
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      // Debug print to see if there's a current user
      _handleError(
          "Current Firebase User: ${firebaseUser?.uid ?? 'No user found'}");

      // Clear user state if no Firebase user
      if (firebaseUser == null) {
        _currentUser = null;
        notifyListeners();
        return false; // No user is logged in
      }

      // For email/password users, check verification
      if (firebaseUser.providerData
              .any((info) => info.providerId == 'password') &&
          !firebaseUser.emailVerified) {
        _handleError("Email not verified, signing out");
        await FirebaseAuth.instance.signOut();
        _currentUser = null;
        notifyListeners();
        return false;
      }

      // Fetch user data from Firestore
      try {
        DocumentSnapshot userDoc =
            await _authRepository.getUserData(firebaseUser.uid);

        if (userDoc.exists) {
          _currentUser = AppUser.fromFirestore(userDoc);
          notifyListeners();
          return true; // User is authenticated
        } else {
          _handleError("User not found in Firestore");
          // Sign out from Firebase Auth if no Firestore record
          await FirebaseAuth.instance.signOut();
          _currentUser = null;
          notifyListeners();
          return false;
        }
      } catch (e) {
        _handleError("Error fetching user data: $e");
        // Sign out if there's an error fetching user data
        await FirebaseAuth.instance.signOut();
        _currentUser = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _handleError('Authentication Error: $e');
      _currentUser = null;
      notifyListeners();
      return false;
    }
  }

  // Signup method with Firestore integration
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (password != confirmPassword) {
      _handleError('Passwords do not match');
      return;
    }

    try {
      UserCredential userCredential =
          await _authRepository.signUpWithEmail(email, password);
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
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign In with Email & Fetch User Data
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential =
          await _authRepository.signInWithEmail(email, password);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null && firebaseUser.emailVerified) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc =
            await _authRepository.getUserData(firebaseUser.uid);

        if (userDoc.exists) {
          _currentUser = AppUser.fromFirestore(userDoc);
          notifyListeners();

          _showToast('Sign in successful');
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          _handleError('User data not found in Firestore');
        }
      } else {
        _showToast('Please verify your email before logging in.');
        await firebaseUser?.sendEmailVerification();
        await _authRepository.signOut();
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset Password
  Future<void> resetPassword(String email, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(email);
      _showToast('Password reset email sent.');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google Sign In with Firestore Integration
  Future<void> signInWithGoogle(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser =
          await _authRepository.signInWithGoogle();

      if (googleUser == null) {
        _handleError('Google sign in cancelled');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await _authRepository.getGoogleAuth(googleUser);
      final AuthCredential credential =
          _authRepository.getGoogleCredential(googleAuth);

      UserCredential userCredential =
          await _authRepository.signInWithGoogleCredential(credential);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        DocumentSnapshot userDoc =
            await _authRepository.getUserData(firebaseUser.uid);

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

        _showToast('Google sign in successful');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } catch (e) {
      _handleError('Google Sign-In Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
    String? email,
  }) async {
    if (_currentUser == null) return;

    Map<String, dynamic> updates = {};
    if (displayName != null) updates['displayName'] = displayName;
    if (email != null) updates['email'] = email; // Correctly update email
    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl; // Correctly update photoUrl
    }

    await _authRepository.updateUserProfile(_currentUser!.uid, updates);

    // Update local user model
    _currentUser = AppUser(
      uid: _currentUser!.uid,
      email: email ?? _currentUser!.email, // Ensure email is updated correctly
      displayName: displayName ?? _currentUser!.displayName,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
      createdAt: _currentUser!.createdAt,
      preferences: _currentUser!.preferences,
    );

    notifyListeners();
  }

  Future<String> uploadProfilePhoto(File imageFile) async {
    // Example: Upload the image to Firebase Storage or your backend
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_photos/${currentUser!.uid}.jpg');

    final uploadTask = await storageRef.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL(); // Return the photo URL
  }

  // Sign Out
// Sign Out
  Future<void> signOut(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Sign out from each provider individually with try-catch blocks
      try {
        await _authRepository.signOutGoogle();
      } catch (e) {
        _handleError('Google sign out error: $e');
        // Continue with other sign outs regardless
      }

      try {
        await _authRepository.signOutFacebook();
      } catch (e) {
        _handleError('Facebook sign out error: $e');
        // Continue with other sign outs regardless
      }

      // Final sign out from Firebase
      await _authRepository.signOut();

      // Clear current user state
      _currentUser = null;

      _showToast('Signed out successfully');

      // Navigate after successful sign out
      if (context.mounted) {
        // Check if context is still valid
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _handleError('Logout Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Error Handling
  void _handleAuthError(FirebaseAuthException e) {
    _handleError('Error: ${e.message}');
  }

  void _handleError(String message) {
    _errorMessage = message;
    _showToast(message);
    notifyListeners();
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM);
  }
}
