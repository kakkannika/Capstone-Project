import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/firebase_options.dart';
import 'package:tourism_app/presentation/screens/dashboard/Screens/dashboard_screen.dart';
import 'package:tourism_app/providers/placecrud.dart';

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
        ChangeNotifierProvider(create: (context) => PlaceCrudService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tourism App Admin Panel',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: DashboardScreen(),
      ),
    );
  }
}
