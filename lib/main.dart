import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/firebase_options.dart';
import 'package:tourism_app/models/user_model.dart';
import 'package:tourism_app/providers/auth/auth_provider.dart';
import 'package:tourism_app/providers/place_provider.dart';
import 'package:tourism_app/services/auth_service.dart';
import 'package:tourism_app/views/auth/get_start_screen.dart';
import 'package:tourism_app/providers/trip_provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<PlaceProvider>(
          create: (_) => PlaceProvider(),
        ),
        StreamProvider<AppUser?>(
          create: (context) => context.read<AuthService>().user,
          initialData: null,
        ),
        ChangeNotifierProvider<TripViewModel>(
          create: (_) => TripViewModel(),
        ),
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
