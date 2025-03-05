import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServiceProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // User state
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Authentication status
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Signup method
  Future<void> signup({
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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      _currentUser = userCredential.user;
      await sendEmailVerification(context);
      
      // Start checking for email verification
      _checkEmailVerification(context);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Email Verification
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      await _currentUser?.sendEmailVerification();
      _showToast('Verification email sent');
    } on FirebaseAuthException catch (e) {
      _handleError(e.message ?? 'Verification email failed');
    }
  }

  // Check Email Verification
  void _checkEmailVerification(BuildContext context) {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _currentUser?.reload();
      
      if (_currentUser != null && _currentUser!.emailVerified) {
        timer.cancel();
        // Navigation should be handled in the UI layer
        _showToast('Email verified successfully');
      }
    });
  }

  // Sign In with Email
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      _currentUser = userCredential.user;
      _showToast('Sign in successful');
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
      await _auth.sendPasswordResetEmail(email: email);
      _showToast('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _currentUser?.updatePassword(newPassword);
      _showToast('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Facebook Sign In
  Future<void> signInWithFacebook(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = 
          FacebookAuthProvider.credential(accessToken.tokenString);
        
        UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
        
        _currentUser = userCredential.user;
        _showToast('Facebook sign in successful');
      } else {
        _handleError('Facebook login failed');
      }
    } catch (e) {
      _handleError('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        _handleError('Google sign in cancelled');
        return;
      }

      final GoogleSignInAuthentication googleAuth = 
        await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = 
        await _auth.signInWithCredential(credential);
      
      _currentUser = userCredential.user;
      _showToast('Google sign in successful');
    } catch (e) {
      _handleError('Google Sign-In Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Phone Number Authentication
  Future<void> sendOTP(String phoneNumber, Function(String) onCodeSent) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _currentUser = _auth.currentUser;
        notifyListeners();
      },
      verificationFailed: (FirebaseAuthException e) {
        _handleError('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Timeout: $verificationId");
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // Verify OTP
  Future<bool> verifyOTP(String verificationId, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      UserCredential userCredential = 
        await _auth.signInWithCredential(credential);
      
      _currentUser = userCredential.user;
      _showToast('Phone number verified');
      
      return userCredential.user != null;
    } catch (e) {
      _handleError('Error verifying OTP: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
      await _auth.signOut();
      
      _currentUser = null;
      _showToast('Signed out successfully');
    } catch (e) {
      _handleError('Error signing out: $e');
    }
    notifyListeners();
  }

  // Error Handling Methods
  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        _handleError('The password provided is too weak');
        break;
      case 'email-already-in-use':
        _handleError('An account already exists with that email');
        break;
      case 'invalid-email':
        _handleError('No user found for that email');
        break;
      case 'wrong-password':
        _handleError('Wrong password provided');
        break;
      case 'requires-recent-login':
        _handleError('Please log in again to update your password');
        break;
      default:
        _handleError('Authentication error: ${e.message}');
    }
  }

  void _handleError(String message) {
    _errorMessage = message;
    _showToast(message);
    notifyListeners();
  }

  // Toast Message
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}