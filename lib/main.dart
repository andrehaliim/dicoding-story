import 'package:flutter/material.dart';
import 'package:story/pages/home-page.dart';
import 'package:story/pages/login-page.dart';
import 'package:story/proxys/login-proxy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final auth = LoginProxy();
    final result = await auth.isLoggedIn();

    setState(() {
      isLoggedIn = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Dicoding Story',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLoggedIn! ? const HomePage() : const LoginPage(),
    );
  }
}
