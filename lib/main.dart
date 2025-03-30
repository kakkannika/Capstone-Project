import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/firebase_options.dart';
import 'package:tourism_app/ui/providers/budget_provider.dart';
import 'package:tourism_app/ui/providers/chatbot_provider.dart';
import 'package:tourism_app/ui/providers/favorite_provider.dart';
import 'package:tourism_app/ui/providers/place_provider.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';
import 'package:tourism_app/ui/screens/auth/auth_wrapper.dart';
import 'package:tourism_app/config/env_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await EnvConfig.init();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const AppStarter());
}

class AppStarter extends StatelessWidget {
  const AppStarter({super.key});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthServiceProvider>(
      future: AuthServiceProvider.createInitialized(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing: ${snapshot.error}'),
              ),
            ),
          );
        }
        
        return MyApp(authProvider: snapshot.data!);
      },
    );
  }
}

class MyApp extends StatelessWidget {
  final AuthServiceProvider authProvider;
  
  const MyApp({super.key, required this.authProvider});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (context) => ChatbotProvider(apiUrl: 'https://eee6-45-119-135-16.ngrok-free.app/chat'),
        ),
        ChangeNotifierProvider(create: (context) => PlaceProvider()),
        ChangeNotifierProvider(create: (context) => TripProvider()),
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tourism App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
        },
      ),
    );
  }
}
