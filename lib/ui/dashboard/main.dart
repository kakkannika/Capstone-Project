import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/data/repository/firebase/place_firebase_repository.dart';
import 'package:tourism_app/firebase_options.dart';
import 'package:tourism_app/ui/dashboard/provider/user_provider.dart';
import 'package:tourism_app/ui/dashboard/screen/main_screen.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/ui/providers/place_provider.dart';

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
            create: (context) => PlaceProvider(PlaceFirebaseRepository())),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tourism App Admin Panel',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainScreen(),
      ),
    );
  }
}
