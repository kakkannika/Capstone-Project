import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tourism_app/models/user_model.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  AppUser? get currentUser => userFromFirebaseUser(_auth.currentUser);
  

  // Auth state stream - returns AppUser objects
  Stream<AppUser?> get user {
    print("AuthService: Getting user stream");
    return _auth.authStateChanges().map((User? firebaseUser) {
      final appUser = userFromFirebaseUser(firebaseUser);
      print("AuthService: Stream emitting AppUser: ${appUser?.uid ?? 'null'}");
      return appUser;
    });
  }

  // Convert Firebase User to AppUser
  AppUser? userFromFirebaseUser(User? firebaseUser) {
    if (firebaseUser == null) return null;
    
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName ?? (firebaseUser.isAnonymous ? "Guest" : null),
      isAnonymous: firebaseUser.isAnonymous,
      // Add any other fields you need from the Firebase User
    );
  }

  

  // Sign in as guest
  Future<AppUser?> signInAsGuest() async {
    try {
      print("AuthService: Starting anonymous sign-in");
      final result = await _auth.signInAnonymously();
      User? user = result.user;
      
      // Set display name for the guest user if needed
      if (user != null && user.displayName == null) {
        await user.updateDisplayName("Guest User");
        await user.reload();
        user = _auth.currentUser; // Get the updated user
      }
      
      print("AuthService: Anonymous sign-in successful, user id: ${user?.uid ?? 'null'}");
      return userFromFirebaseUser(user);
    } catch (e) {
      print("AuthService: Error signing in anonymously: ${e.toString()}");
      throw e;
    }
  }

  //sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
  try {
    print("AuthService: Signing in with email and password");
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
    User? user = result.user;
    
    print("AuthService: Sign in successful, user id: ${user?.uid ?? 'null'}");
    return userFromFirebaseUser(user);
  } catch (e) {
    print("AuthService: Error signing in with email/password: ${e.toString()}");
    throw e;
  }
}

 // Sign up with name, email, and password
Future<AppUser?> signUp(String name, String email, String password) async {
  try {
    print("AuthService: Starting user registration for email: $email");
    
    // 1. Create user in Firebase Auth
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // 2. Update display name
    User? user = result.user;
    if (user != null) {
      await user.updateDisplayName(name);
      
      // Important: Reload the user to get updated profile
      await user.reload();
      
      // Get the user again with updated profile
      user = _auth.currentUser;
      
      print("AuthService: User registered successfully with ID: ${user?.uid}");
    }
    
    // 3. Return AppUser
    return userFromFirebaseUser(user);
  } catch (e) {
    print("AuthService: Error during registration: ${e.toString()}");
    if (e is FirebaseAuthException) {
      throw e;
    }
    throw FirebaseAuthException(
      code: 'unknown',
      message: 'An unknown error occurred: ${e.toString()}'
    );
  }
}
  //sign in with google account

  //sign out
  // sign out
Future<void> signOut() async {
  try {
    return await _auth.signOut();
  } catch (e) {
    print('Error signing out: ${e.toString()}');
    throw e;
  }
}

  //reset password

  //change password
}