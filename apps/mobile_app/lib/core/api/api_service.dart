import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator to access host's localhost
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setToken(data['access_token']);
      return data;
    }
    throw Exception('Login failed');
  }

  static Future<Map<String, dynamic>> register(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      setToken(data['access_token']);
      return data;
    }
    throw Exception('Register failed');
  }

  static Future<List<dynamic>> getHabits() async {
    final res = await http.get(Uri.parse('$baseUrl/habits'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load habits');
  }

  static Future<Map<String, dynamic>> createHabit(Map<String, dynamic> data) async {
    final res = await http.post(Uri.parse('$baseUrl/habits'), headers: _headers, body: jsonEncode(data));
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception('Failed to create habit');
  }

  static Future<Map<String, dynamic>> updateHabit(String id, Map<String, dynamic> data) async {
    final res = await http.put(Uri.parse('$baseUrl/habits/$id'), headers: _headers, body: jsonEncode(data));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to update habit');
  }

  static Future<void> deleteHabit(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/habits/$id'), headers: _headers);
    if (res.statusCode != 200) throw Exception('Failed to delete habit');
  }

  static Future<Map<String, dynamic>> toggleHabit(String id, String date) async {
    final res = await http.post(
      Uri.parse('$baseUrl/habits/$id/toggle'),
      headers: _headers,
      body: jsonEncode({'date': date}),
    );
    if (res.statusCode == 201 || res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to toggle habit');
  }

  static Future<Map<String, dynamic>> generateHabits(String message) async {
    final res = await http.post(Uri.parse('$baseUrl/ai/chat'), headers: _headers, body: jsonEncode({'message': message}));
    if (res.statusCode == 201) {
      return jsonDecode(res.body)['aiResponse'];
    }
    throw Exception('Failed to communicate with AI');
  }
}
