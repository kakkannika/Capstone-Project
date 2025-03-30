import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/ui/screens/auth/login_screen.dart';
import 'package:tourism_app/ui/screens/home/home_page.dart';
import 'package:tourism_app/ui/widgets/loading_screen.dart';

/// AuthWrapper widget that handles authentication state and routing.
/// This widget is responsible for checking if the user is authenticated
/// and redirecting them to the appropriate screen based on their auth state.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _authFuture;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid initialization during build
    Future.microtask(() {
      final authProvider = Provider.of<AuthServiceProvider>(context, listen: false);
      _authFuture = authProvider.initializeAuth().then((result) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
        return result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing
    if (_isInitializing) {
      return const LoadingScreen(message: "Checking login status...");
    }

    // Get auth provider - need to listen for changes
    return Consumer<AuthServiceProvider>(
      builder: (context, auth, _) {
        // If not initialized yet, show loading
        if (!auth.isInitialized) {
          return const LoadingScreen(message: "Loading user data...");
        }
        
        // Redirect based on authentication state
        if (auth.isAuthenticated) {
          print("AuthWrapper: User is authenticated, showing HomeScreen");
          return const HomeScreen();
        } else {
          print("AuthWrapper: User is not authenticated, showing LoginScreen");
          return LoginScreen();
        }
      }
    );
  }
} 