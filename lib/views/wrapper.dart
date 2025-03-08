import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/user_model.dart';
import 'package:tourism_app/views/auth/login_screen.dart';
import 'package:tourism_app/views/home/home_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    print("Wrapper BUILD: Received AppUser: ${user?.uid ?? 'null'}, isLoggedIn: ${user != null}");
    return user != null ? const HomeScreen() : const LoginScreen();
  }
}