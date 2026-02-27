import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final _url = Uri.parse('https://graphql.anilist.co');

  Future request(
    String query, [
    Map<String, dynamic> variables = const {},
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("token");
    Map<String, String> headers = {
      "credentials": 'include',
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    try {
      final response = await post(
        _url,
        body: json.encode({'query': query, 'variables': variables}),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      final Map<String, dynamic> body = json.decode(response.body);

      if (body.containsKey('errors')) {
        throw StateError(
          (body['errors'] as List)
              .map((e) => e['message'].toString())
              .join(', '),
        );
      }

      return body['data'];
    } on SocketException {
      throw Exception('Failed to connect');
    } on TimeoutException {
      throw Exception('Request took too long');
    }
  }
}
