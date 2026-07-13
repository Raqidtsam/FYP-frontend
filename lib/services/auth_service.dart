import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.126.217.239:8000/api';

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String nationality = '',
    String contact = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email, 'password': password,
        'full_name': fullName, 'nationality': nationality, 'contact': contact,
      }),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      await _saveToken(data['access']);
      await _saveUserData(data['user']);
      return {'success': true, 'user': data['user']};
    }
    return {'success': false, 'error': data['error'] ?? 'Registration failed'};
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      await _saveToken(data['access']);
      await _saveUserData(data['user']);
      return {'success': true, 'user': data['user']};
    }
    return {'success': false, 'error': data['error'] ?? 'Login failed'};
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) return {'success': true, 'message': data['message']};
    return {'success': false, 'error': data['error'] ?? 'Failed'};
  }

  Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'otp': otp, 'new_password': newPassword}),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) return {'success': true, 'message': data['message']};
    return {'success': false, 'error': data['error'] ?? 'Failed'};
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    if (data != null) return json.decode(data);
    return null;
  }

  Future<bool> isAdmin() async {
    final userData = await getUserData();
    return userData?['is_admin'] == true || userData?['email'] == 'admin@smartgeo.com';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
