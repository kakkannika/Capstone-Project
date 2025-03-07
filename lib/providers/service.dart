// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tourism_app/presentation/screens/auth/login_screen.dart';
import 'package:tourism_app/presentation/screens/home/home_screen.dart';

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
      // Create user account
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      _currentUser = userCredential.user;

      // Send verification email automatically
      await _currentUser?.sendEmailVerification();

      // Show simple verification message
      _showToast(
          'Verification email sent. Please verify your email before logging in.');

      // Sign out the user until they verify their email
      await _auth.signOut();

      // Navigate to login screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        password: password,
      );

      _currentUser = userCredential.user;

      // Check if email is verified before allowing login
      if (_currentUser != null && _currentUser!.emailVerified) {
        _showToast('Sign in successful');

        // Successfully verified and logged in - go to home screen
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        // Email not verified - show error and sign out
        _showToast(
            'Please verify your email first. Check your inbox for the verification link.');

        // Resend verification email
        await _currentUser?.sendEmailVerification();

        // Sign out since we don't want unverified users logged in
        await _auth.signOut();
        _currentUser = null;
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
      await _auth.sendPasswordResetEmail(email: email);
      _showToast('Password reset email sent');
      _checkIfPasswordReset(context);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _checkIfPasswordReset(BuildContext context) async {
    User? user = _auth.currentUser;
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      await user?.reload(); // Reload the user to get the latest information
      user = _auth.currentUser; // Update the user instance

      if (user != null && user!.emailVerified) {
        timer.cancel(); // Stop the timer
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    LoginScreen())); // Navigate to Login Screen
      }
    });
  }

  // Update Password - Requires email verification
  Future<void> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if user is verified
      if (_currentUser != null && !_currentUser!.emailVerified) {
        _handleError('Email must be verified before updating password');
        return;
      }

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
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
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
  Future<void> signInWithGoogle(BuildContext context) async {
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
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
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
  Future<bool> verifyOTP(
      String verificationId, String otp, BuildContext context) async {
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

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));

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
  Future<void> signOut(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
      await _auth.signOut();

      _currentUser = null;
      _showToast('Signed out successfully');

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
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
        _handleError('Invalid email format');
        break;
      case 'user-not-found':
        _handleError('No user found with this email');
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
