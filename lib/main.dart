import 'package:flutter/material.dart';
import 'package:story/pages/home-page.dart';
import 'package:story/pages/login-page.dart';
import 'package:story/proxys/login-proxy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = LoginProxy();
  final bool isLoggedIn = await auth.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dicoding Story',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
