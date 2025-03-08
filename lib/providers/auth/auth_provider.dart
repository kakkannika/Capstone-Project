import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tourism_app/models/user_model.dart';
import 'package:tourism_app/services/auth_service.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService ;

  User? _user;
  AppUser? _appUser;

  User? get user => _user;
  AppUser? get appUser => _appUser;

  bool get isLoggedIn => _appUser != null;

AuthViewModel(this._authService) {
  print("AuthViewModel: Constructor called - Setting up listener");
  
  // IMMEDIATELY check the current user
  _checkCurrentUser();
  
  // Then listen for future auth changes
  _authService.user.listen((AppUser? appUser) {
    print("AuthViewModel: Auth state listener triggered - AppUser: ${appUser?.uid}");
    _appUser = appUser;
    _user = FirebaseAuth.instance.currentUser; // Get the current Firebase user
    print("AuthViewModel: Updated _appUser: ${_appUser?.uid}, _user: ${_user?.uid}");
    notifyListeners();
  });
}

void _checkCurrentUser() {
  final currentAppUser = _authService.currentUser;
  if (currentAppUser != null) {
    print("AuthViewModel: Current AppUser found: ${currentAppUser.uid}");
    _appUser = currentAppUser;
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }
}


Future<AppUser?> signInAsGuest() async {
  try {
    // This returns the AppUser directly
    final appUser = await _authService.signInAsGuest();
    
    // Manually update the local state
    _appUser = appUser;
    _user = FirebaseAuth.instance.currentUser;
    
    print("AuthViewModel: Guest sign-in completed, AppUser: ${_appUser?.uid}");
    notifyListeners();
    
    return appUser;
  } catch (e) {
    print("AuthViewModel: Error signing in as guest: ${e.toString()}");
    throw e;
  }
}

  // Register with email/password functionality
  Future<AppUser?> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      print("AuthViewModel: Starting registration for email: $email, name: $name");
      final appUser = await _authService.signUp(name, email, password);
      
      // Manually update the local state
      _appUser = appUser;
      _user = FirebaseAuth.instance.currentUser;
      
      print("AuthViewModel: Registration completed, AppUser: ${_appUser?.uid}, name: ${_appUser?.displayName}");
      notifyListeners();
      
      return appUser;
    } catch (e) {
      print("AuthViewModel: Registration error: ${e.toString()}");
      throw e;
    }
  }

  // Sign in with email/password functionality
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print("AuthViewModel: Attempting sign in with email: $email");
      // You need to add this method to your AuthService
      final appUser = await _authService.signInWithEmailAndPassword(email, password);
      
      // Manually update the local state
      _appUser = appUser;
      _user = FirebaseAuth.instance.currentUser;
      
      print("AuthViewModel: Sign in completed, AppUser: ${_appUser?.uid}");
      notifyListeners();
      
      return appUser;
    } catch (e) {
      print("AuthViewModel: Sign in error: ${e.toString()}");
      throw e;
    }
  }

 Future<void> signOut() async {
  try {
    await _authService.signOut();
      // Clear local state
      _appUser = null;
      _user = null;
  } catch (e) {
    print('Error in view model during sign out: ${e.toString()}');
    throw e;
  }
}
}
