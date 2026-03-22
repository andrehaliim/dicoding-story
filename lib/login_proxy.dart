import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginProxy {
  final url = 'https://story-api.dicoding.dev/v1';

  Future<bool> doLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse('$url/login'),
      body: {'email': email, 'password': password},
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final result = jsonResponse['loginResult'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);
      await prefs.setString('userId', result['userId']);
      await prefs.setString('name', result['name']);
      return true;
    } else {
      return false;
    }
  }

  Future<String> doRegister(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$url/register'),
      body: {'name': name, 'email': email, 'password': password},
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<bool> doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('name');
    return true;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }
}
