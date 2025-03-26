import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tourism_app/models/user/user_model.dart';

abstract class AuthenticationRepository {
  Future<UserCredential> signUpWithEmail(String email, String password);
  Future<void> saveUserToFirestore(AppUser user);
  Future<void> sendEmailVerification(User user);
  Future<void> signOut();
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<DocumentSnapshot> getUserData(String uid);
  Future<void> resetPassword(String email);
  Future<GoogleSignInAccount?> signInWithGoogle();
  Future<GoogleSignInAuthentication> getGoogleAuth(GoogleSignInAccount googleUser);
  AuthCredential getGoogleCredential(GoogleSignInAuthentication googleAuth);
  Future<UserCredential> signInWithGoogleCredential(AuthCredential credential);
  Future<void> signOutGoogle();
  Future<void> signOutFacebook();
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates);

}
