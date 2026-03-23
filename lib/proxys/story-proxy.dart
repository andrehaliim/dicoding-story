import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/models/story-model.dart';
import '../helpers/log-helper.dart';

class StoryProxy {
  final url = 'https://story-api.dicoding.dev/v1';

  Future<List<StoryModel>> getAllStories() async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString('token');

    final requestUrl = '$url/stories';
    final requestHeaders = {'Authorization': 'Bearer $token'};
    final response = await http.get(
      Uri.parse(requestUrl),
      headers: requestHeaders,
    );
    LogHelper.apiFetchLog(
      method: 'GET',
      url: requestUrl,
      parameters: requestHeaders,
      response: response,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body)['listStory'];
      return jsonList.map((json) => StoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stories');
    }
  }
}
