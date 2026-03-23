import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/log-helper.dart';

class LoginProxy {
  final url = 'https://story-api.dicoding.dev/v1';

  Future<bool> doLogin(String email, String password) async {
    final requestUrl = '$url/login';
    final requestBody = {'email': email, 'password': password};
    final response = await http.post(Uri.parse(requestUrl), body: requestBody);
    LogHelper.apiFetchLog(
      method: 'POST',
      url: requestUrl,
      parameters: requestBody,
      response: response,
    );
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final result = jsonResponse['loginResult'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);
      await prefs.setString('userId', result['userId']);
      await prefs.setString('name', result['name']);
      return true;
    } else {
      throw jsonResponse['message'] ?? 'Login failed. Please try again.';
    }
  }

  Future<bool> doRegister(String name, String email, String password) async {
    final requestUrl = '$url/register';
    final requestBody = {'name': name, 'email': email, 'password': password};
    final response = await http.post(Uri.parse(requestUrl), body: requestBody);
    LogHelper.apiFetchLog(
      method: 'POST',
      url: requestUrl,
      parameters: requestBody,
      response: response,
    );
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw jsonResponse['message'] ?? 'Registration failed. Please try again.';
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
