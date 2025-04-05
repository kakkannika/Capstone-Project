import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:tourism_app/domain/models/user/user_model.dart';
import 'package:tourism_app/data/repository/authentication_repository.dart';

class AuthFirebaseRepository extends AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> saveUserToFirestore(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  @override
  Future<void> sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    return await GoogleSignIn().signIn();
  }

  @override
  Future<GoogleSignInAuthentication> getGoogleAuth(
      GoogleSignInAccount googleUser) async {
    return await googleUser.authentication;
  }

  @override
  AuthCredential getGoogleCredential(GoogleSignInAuthentication googleAuth) {
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  @override
  Future<void> signOutGoogle() async {
    await GoogleSignIn().signOut();
  }

  @override
  Future<void> signOutFacebook() async {
    await FacebookAuth.instance.logOut();
  }

  @override
  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> updates) async {
    await _firestore.collection('users').doc(uid).update(updates);
  }

  @override
  Future<UserCredential> signInWithGoogleCredential(
      AuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }
}
