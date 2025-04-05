// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tourism_app/ui/providers/auth_provider.dart';
// import 'package:tourism_app/ui/screens/auth/login_screen.dart';
// import 'package:tourism_app/ui/screens/home/home_page.dart';

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});

//   @override
//   State<AuthWrapper> createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   bool _isInitializing = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAuth();
//   }

//   Future<void> _initializeAuth() async {
//     final authProvider =
//         Provider.of<AuthServiceProvider>(context, listen: false);
//     bool isAuthenticated = await authProvider.initializeAuth();
//     print("Init auth result: $isAuthenticated");

//     if (mounted) {
//       setState(() {
//         _isInitializing = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthServiceProvider>(context);

//     // Add debug print to track current user state
//     print(
//         "Current user in AuthWrapper: ${authProvider.currentUser?.uid ?? 'No user'}");

//     // Show loading indicator while initializing
//     if (_isInitializing) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     // Check if user is authenticated
//     if (authProvider.currentUser != null) {
//       return const HomeScreen();
//     } else {
//       return LoginScreen();
//     }
//   }
// }
