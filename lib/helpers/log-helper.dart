import 'dart:developer';

import 'package:http/http.dart' as http;

class LogHelper {
  static void apiFetchLog({
    required String method,
    required String url,
    dynamic parameters,
    required http.Response response,
  }) {
    log('==============================');
    log('API FETCH ($method): $url');
    if (parameters != null) {
      log('API PARAMETER: $parameters');
    }
    log('API RESPONSE CODE: ${response.statusCode}');
    log('API RESPONSE BODY: ${response.body}');
    log('==============================');
  }
}
