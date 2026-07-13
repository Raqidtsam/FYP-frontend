import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static const String baseUrl = 'http://10.126.217.239:8000/api';

  Future<Map<String, dynamic>?> getProfile() async {
    final token = await AuthService().getToken();

    print('=== FLUTTER DEBUG PROFILE ===');
    print('Token from storage: $token');
    print('Token length: ${token?.length}');

    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? email,
    String? nationality,
    String? contact,
    String? password,
    String? profilePicturePath,
  }) async {
    final token = await AuthService().getToken();
    if (token == null) return {'success': false, 'error': 'Not logged in'};

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/auth/profile/update/'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      if (fullName != null) request.fields['full_name'] = fullName;
      if (email != null) request.fields['email'] = email;
      if (nationality != null) request.fields['nationality'] = nationality;
      if (contact != null) request.fields['contact'] = contact;
      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }

      if (profilePicturePath == 'remove') {
        request.fields['remove_picture'] = 'true';
      } else if (profilePicturePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
              'profile_picture', profilePicturePath),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (response.statusCode == 200) {
        return {'success': true, 'user': data['user']};
      }
      return {'success': false, 'error': data['error'] ?? 'Update failed'};
    } catch (e) {
      print('Update profile exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}