import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

class NetworkService {
  static const String _url = 'http://localhost:8000/data.json';  // Your JSON URL

final Dio _dio = Dio()..interceptors.add(LogInterceptor(responseBody: true));


  Future<Map<String, dynamic>> fetchPrayerData() async {
    try {
      final response = await _dio.get(_url);
 
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          throw Exception('Invalid JSON format');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

// load data from asset folder 
    Future<Map<String, dynamic>> fetchPrayerDataLocal() async {
    try {
      // Load the JSON file from assets
      final String response = await rootBundle.loadString('assets/data.json');
      return json.decode(response);
    } catch (e) {
      throw Exception('Error loading local data: $e');
    }
  }
}
