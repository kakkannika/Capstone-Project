// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tourism_app/presentation/screens/auth/login_screen.dart';
import 'package:tourism_app/presentation/screens/auth/new_password_screen.dart';
import 'package:tourism_app/presentation/screens/home/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tourism_app/providers/snackbar.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var verificationId = '';

  // Signup with Email & Password
  // Signup with Email & Password
  Future<void> signup({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    if (password != confirmPassword) {
      _showToast('Passwords do not match');
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await sendEmailVerification(context);

      // Start checking for email verification
      _checkEmailVerification(context);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email';
      }
      _showToast(message);
    }
    notifyListeners();
  }

// Method to check email verification
  void _checkEmailVerification(BuildContext context) async {
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

  //Email Verification
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      await _auth.currentUser!.sendEmailVerification();
      showSnackBar(context, 'Verification email sent');
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  // Signin with Email & Password
  Future<void> signinEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user';
      }
      _showToast(message);
    }
  }

  // For reset Email password
  // Reset password method
  Future<void> resetPassword(String email, BuildContext context) async {
    await _auth.sendPasswordResetEmail(email: email);
    await sendEmailVerification(context);
    _checkIfPasswordReset(context);
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
                    const NewPasswordScreen())); // Navigate to Login Screen
      }
    });
  }

// Update password method
  Future<void> updatePassword(String newPassword) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        _showToast('Password updated successfully.');
      } on FirebaseAuthException catch (e) {
        String message = '';
        if (e.code == 'requires-recent-login') {
          message = 'Please log in again to update your password.';
        } else {
          message = 'Error: ${e.message}';
        }
        _showToast(message);
      }
    } else {
      _showToast('No user is currently logged in.');
    }
  }

  // Sign in with Facebook
  Future<UserCredential?> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
        return userCredential;
      } else {
        _showToast("Facebook login failed");
      }
    } catch (e) {
      _showToast("Error: $e");
    }
    return null;
  }

  // Logout
  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

// signin with google account
  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the login
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return true; // Successful login
    } catch (e) {
      print("Google Sign-In Error: $e");
      return false; // Failed login
    }
  }

  Future<void> googlesignOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  // Helper method to show toast messages
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> sendOTP(String phoneNumber, Function(String) onCodeSent) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-signs in for some devices
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Timeout: $verificationId");
      },
    );
  }

  Future<bool> verifyOTP(String verificationId, String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user != null;
    } catch (e) {
      print("Error verifying OTP: $e");
      return false;
    }
  }

  // Sign out from all services
  Future<void> signOutFromAll() async {
    try {
      // Sign out from Google
      await GoogleSignIn().signOut();

      // Sign out from Facebook
      await FacebookAuth.instance.logOut();

      // Sign out from Firebase Auth
      await _auth.signOut();

      _showToast('Signed out from all services successfully.');
    } on FirebaseAuthException catch (e) {
      _showToast('Error signing out: ${e.message}');
    }
  }
}