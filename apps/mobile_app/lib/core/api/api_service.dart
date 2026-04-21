import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _liveUrl = 'https://your-production-url.com'; // TODO: Update later

  static String get baseUrl {
    if (kReleaseMode) return _liveUrl;
    
    // In debug mode, use the appropriate local address
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000'; // Android emulator access
    }
    return 'http://localhost:3000'; // iOS/Desktop/Web access
  }

  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static void setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static bool get isAuthenticated => _token != null;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
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

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
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

  static Future<Map<String, dynamic>> createHabit(
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/habits'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception('Failed to create habit');
  }

  static Future<Map<String, dynamic>> updateHabit(
    String id,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/habits/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to update habit');
  }

  static Future<void> deleteHabit(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/habits/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception('Failed to delete habit');
  }

  static Future<Map<String, dynamic>> toggleHabit(
    String id,
    String date,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/habits/$id/toggle'),
      headers: _headers,
      body: jsonEncode({'date': date}),
    );
    if (res.statusCode == 201 || res.statusCode == 200)
      return jsonDecode(res.body);
    throw Exception('Failed to toggle habit');
  }

  static Future<Map<String, dynamic>> generateHabits(String message) async {
    final res = await http.post(
      Uri.parse('$baseUrl/ai/chat'),
      headers: _headers,
      body: jsonEncode({'message': message}),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body)['aiResponse'];
    }
    throw Exception('Failed to communicate with AI');
  }

  // Goals API
  static Future<Map<String, dynamic>> evaluateGoal(String prompt, {int? durationDays}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/goals/evaluate'),
      headers: _headers,
      body: jsonEncode({
        'prompt': prompt,
        if (durationDays != null) 'durationDays': durationDays,
      }),
    );
    if (res.statusCode == 201 || res.statusCode == 200)
      return jsonDecode(res.body);
    throw Exception('Failed to evaluate goal');
  }

  static Future<Map<String, dynamic>> createGoal(
    String prompt,
    Map<String, dynamic> aiPlan, {
    int? durationDays,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: _headers,
      body: jsonEncode({
        'prompt': prompt,
        'aiPlan': aiPlan,
        if (durationDays != null) 'durationDays': durationDays,
      }),
    );
    if (res.statusCode == 201 || res.statusCode == 200)
      return jsonDecode(res.body);
    throw Exception('Failed to create goal');
  }

  static Future<List<dynamic>> getGoals() async {
    final res = await http.get(Uri.parse('$baseUrl/goals'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load goals');
  }

  static Future<Map<String, dynamic>> getGoalDetails(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/goals/$id'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load goal details');
  }

  static Future<Map<String, dynamic>> updateActionItem(
    String id,
    bool isCompleted,
  ) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/goals/action-items/$id'),
      headers: _headers,
      body: jsonEncode({'isCompleted': isCompleted}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to update action item');
  }

  static Future<Map<String, dynamic>> generateActionItemSteps(String id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/goals/action-items/$id/generate-steps'),
      headers: _headers,
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to generate steps');
  }

  static Future<Map<String, dynamic>> toggleTaskStep(
    String id,
    bool isCompleted,
  ) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/goals/steps/$id'),
      headers: _headers,
      body: jsonEncode({'isCompleted': isCompleted}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to toggle step');
  }

  // Profile API
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to fetch profile');
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to update profile');
  }
}
