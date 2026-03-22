import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/login-page.dart';
import 'package:story/login_proxy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nickname = '';

  @override
  void initState() {
    super.initState();
    getNickname();
  }

  Future<void> getNickname() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      nickname = sharedPreferences.getString('name') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home, $nickname'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final proxy = LoginProxy();
              await proxy.doLogout();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text('Home')),
    );
  }
}
