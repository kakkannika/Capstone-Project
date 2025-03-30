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
import 'package:tourism_app/ui/screens/get_start_screen.dart';
import 'package:tourism_app/config/env_config.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await EnvConfig.init();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthServiceProvider()),
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
        home:  GetStartedScreen(),
      ),
    );
  }
}
