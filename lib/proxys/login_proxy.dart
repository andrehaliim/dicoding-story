import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/models/login_request.dart';
import 'package:story/models/login_response.dart';
import 'package:story/models/register_request.dart';
import 'package:story/models/register_response.dart';
import '../helpers/log_helper.dart';

class LoginProxy {
  final url = 'https://story-api.dicoding.dev/v1';

  Future<bool> doLogin(String email, String password) async {
  final requestUrl = '$url/login';
  final requestBody = LoginRequest(email: email, password: password).toJson();

  final response = await http.post(
    Uri.parse(requestUrl),
    body: requestBody,
  );

  LogHelper.apiFetchLog(
    method: 'POST',
    url: requestUrl,
    parameters: requestBody,
    response: response,
  );

  final jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    final loginResponse = LoginResponse.fromJson(jsonResponse);
    final result = loginResponse.loginResult;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', result.token);
    await prefs.setString('userId', result.userId);
    await prefs.setString('name', result.name);

    return true;
  } else {
    throw Exception(jsonResponse['message']);
  }
}

  Future<bool> doRegister(String name, String email, String password) async {
  final requestUrl = '$url/register';

  final requestBody = RegisterRequest(name: name, email: email, password: password).toJson();

  final response = await http.post(
    Uri.parse(requestUrl),
    body: requestBody,
  );

  LogHelper.apiFetchLog(
    method: 'POST',
    url: requestUrl,
    parameters: requestBody,
    response: response,
  );

  final jsonResponse = jsonDecode(response.body);
  final registerResponse = RegisterResponse.fromJson(jsonResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  } else {
    throw Exception(registerResponse.message);
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
