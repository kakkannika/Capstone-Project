import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/firebase_options.dart';
import 'package:tourism_app/presentation/screens/get_start_screen.dart';
import 'package:tourism_app/providers/budget_provider.dart';
import 'package:tourism_app/providers/place_provider.dart';
import 'package:tourism_app/providers/auth_provider.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:tourism_app/providers/favorite_provider.dart';

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
        ChangeNotifierProvider(create: (context) => PlaceProvider()),
        ChangeNotifierProvider(create: (context) => TripProvider()),
        ChangeNotifierProvider(create: (context)=> BudgetProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tourism App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const GetStartedScreen(),
      ),
    );
  }
}
