import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AdminService {
  static const String baseUrl = 'http://10.126.217.239:8000/api';

  // Dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load dashboard');
  }

  // Users
  Future<List<dynamic>> getUsers() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load users');
  }

  Future<Map<String, dynamic>> getUserDetail(int userId) async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/$userId/detail/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load user detail');
  }

  Future<void> toggleUserStatus(int userId) async {
    final token = await AuthService().getToken();
    await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/toggle-status/'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> toggleAdminStatus(int userId) async {
    final token = await AuthService().getToken();
    await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/toggle-admin/'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> deleteUser(int userId) async {
    final token = await AuthService().getToken();
    await http.delete(
      Uri.parse('$baseUrl/admin/users/$userId/delete/'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> resetPassword(int userId, String newPassword) async {
    final token = await AuthService().getToken();
    await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/reset-password/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'new_password': newPassword}),
    );
  }

  // Districts
  Future<List<dynamic>> getDistricts() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/districts/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load districts');
  }

  Future<void> updateDistrict(int districtId, Map<String, dynamic> data) async {
    final token = await AuthService().getToken();
    await http.put(
      Uri.parse('$baseUrl/admin/districts/$districtId/update/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
  }

  // Recommendations
  Future<List<dynamic>> getRecommendations() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/recommendations/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load recommendations');
  }

  Future<Map<String, dynamic>> generateRecommendations({int? districtId}) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/admin/recommendations/generate/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'district_id': districtId}),
    );
    return json.decode(response.body);
  }

  Future<void> addRecommendation(int districtId, int sectorId, double score, String reason) async {
    final token = await AuthService().getToken();
    await http.post(
      Uri.parse('$baseUrl/admin/recommendations/add/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'district_id': districtId,
        'sector_id': sectorId,
        'score': score,
        'reason': reason,
      }),
    );
  }

  Future<void> updateRecommendation(int recId, {double? score, String? reason}) async {
    final token = await AuthService().getToken();
    await http.put(
      Uri.parse('$baseUrl/admin/recommendations/$recId/update/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'score': ?score,
        'reason': ?reason,
      }),
    );
  }

  Future<void> deleteRecommendation(int recId) async {
    final token = await AuthService().getToken();
    await http.delete(
      Uri.parse('$baseUrl/admin/recommendations/$recId/delete/'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<List<dynamic>> getSectors() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/sectors/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }

  // System Settings
  Future<Map<String, dynamic>> getSystemInfo() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/system/info/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }

  Future<void> backupDatabase() async {
    final token = await AuthService().getToken();
    await http.post(
      Uri.parse('$baseUrl/admin/system/backup/'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> testEmail(String email) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/admin/system/test-email/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': email}),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getAuditLog() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/system/audit-log/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }

  // Notifications
  Future<Map<String, dynamic>> sendNotification(String title, String body) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/admin/notifications/send/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'title': title, 'body': body}),
    );
    return json.decode(response.body);
  }
}