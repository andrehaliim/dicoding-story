import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/models/story_model.dart';
import 'package:story/models/story_response.dart';
import '../helpers/log_helper.dart';

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
      final jsonBody = jsonDecode(response.body);

      final result = StoryResponse.fromJson(jsonBody);

      return result.listStory;
    } else {
      throw Exception('Failed to load stories');
    }
  }

  Future<List<StoryModel>> getPaginationStories({
    required int page,
    required int size,
  }) async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final requestUrl = '$url/stories?page=$page&size=$size';
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
      final jsonBody = jsonDecode(response.body);

      final result = StoryResponse.fromJson(jsonBody);

      if (result.error) {
        throw Exception(result.message);
      }

      return result.listStory;
    } else {
      throw Exception('Failed to load stories');
    }
  }

  Future<bool> uploadStory({
    required File file,
    required String description,
    double? lat,
    double? lon,
  }) async {
    final bytes = await file.readAsBytes();
    final compressedBytes = await _compressImage(bytes);

    final pref = await SharedPreferences.getInstance();
    final token = pref.getString('token');

    final requestUrl = '$url/stories';
    final requestHeaders = {'Authorization': 'Bearer $token'};
    final request = http.MultipartRequest('POST', Uri.parse(requestUrl));
    request.headers.addAll(requestHeaders);
    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        compressedBytes,
        filename: file.path.split('/').last,
      ),
    );
    request.fields['description'] = description;
    if (lat != null && lon != null) {
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    LogHelper.apiFetchLog(
      method: 'POST',
      url: requestUrl,
      parameters: requestHeaders,
      response: response,
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to upload story');
    }
  }

  Future<List<int>> _compressImage(List<int> bytes) async {
    return await compute((List<int> b) {
      int imageLength = b.length;
      if (imageLength < 1000 * 1024) return b;

      final img.Image? decodedImage = img.decodeImage(Uint8List.fromList(b));
      if (decodedImage == null) return b;

      int compressQuality = 100;
      int length = imageLength;
      List<int> newByte = [];

      do {
        compressQuality -= 10;
        newByte = img.encodeJpg(decodedImage, quality: compressQuality);
        length = newByte.length;
      } while (length > 1000 * 1024 && compressQuality > 10);

      return newByte;
    }, bytes);
  }
}
