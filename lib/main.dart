import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/data/repository/firebase/favorite_firebase_repository.dart';
import 'package:tourism_app/data/repository/firebase/place_firebase_repository.dart';
import 'package:tourism_app/data/repository/firebase/trip_firebase_repository.dart';
import 'package:tourism_app/firebase_options.dart';
import 'package:tourism_app/ui/providers/budget_provider.dart';
import 'package:tourism_app/ui/providers/chatbot_provider.dart';
import 'package:tourism_app/ui/providers/favorite_provider.dart';
import 'package:tourism_app/ui/providers/place_provider.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';
import 'package:tourism_app/ui/screens/get_start_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          create: (context) => ChatbotProvider(
              apiUrl: 'https://eee6-45-119-135-16.ngrok-free.app/chat'),
        ),
        ChangeNotifierProvider(
            create: (context) => PlaceProvider(PlaceFirebaseRepository())),
        ChangeNotifierProvider(
            create: (context) => TripProvider(TripFirebaseRepository())),
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
        ChangeNotifierProvider(
            create: (context) =>
                FavoriteProvider(FavoriteFirebaseRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tourism App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: GetStartedScreen(),
      ),
    );
  }
}
