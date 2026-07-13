import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/district.dart';
import '../models/recommendation.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.126.217.239:8000/api';

  Future<List<District>> getDistricts() async {
    final response = await http.get(Uri.parse('$baseUrl/districts/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> results;
      if (data is Map && data.containsKey('results')) {
        results = data['results'];
      } else {
        results = data;
      }
      return results.map((json) => District.fromJson(json)).toList();
    }
    throw Exception('Failed to load districts');
  }

  Future<List<Recommendation>> getRecommendations(int districtId) async {
    final response = await http.get(Uri.parse('$baseUrl/recommendations/by_district/?district_id=$districtId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> results;
      if (data is Map && data.containsKey('results')) {
        results = data['results'];
      } else {
        results = data;
      }
      return results.map((json) => Recommendation.fromJson(json)).toList();
    }
    throw Exception('Failed to load recommendations');
  }

  Future<Map<String, dynamic>> generateRecommendations(int? districtId) async {
    final body = districtId != null ? {'district_id': districtId} : {};
    final response = await http.post(Uri.parse('$baseUrl/recommendations/generate_ai/'), headers: {'Content-Type': 'application/json'}, body: json.encode(body));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to generate recommendations');
  }

  Future<Map<String, dynamic>?> getDistrictDetail(int districtId) async {
    final response = await http.get(Uri.parse('$baseUrl/districts/$districtId/details/'));
    if (response.statusCode == 200) return json.decode(response.body);
    return null;
  }

  Future<String?> getDistrictImage(String districtName) async {
    final Map<String, String> districtImages = {
      'Mjini': 'https://images.unsplash.com/photo-1590587920186-2e5e06e33c7a?w=800',
      'Magharibi': 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800',
      'Kaskazini A': 'https://images.unsplash.com/photo-1590523278191-995cbcda646b?w=800',
      'Kaskazini B': 'https://images.unsplash.com/photo-1540202404-a2f29016b523?w=800',
      'Kati': 'https://images.unsplash.com/photo-1599745606520-dbe4b4b2ec8b?w=800',
      'Kusini': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      'Wete': 'https://images.unsplash.com/photo-1599745606371-e40cba0c5d9b?w=800',
      'Micheweni': 'https://images.unsplash.com/photo-1590587920186-2e5e06e33c7a?w=800',
      'Mkoani': 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800',
      'Chake Chake': 'https://images.unsplash.com/photo-1569949381669-ecf31ae8f613?w=800',
    };
    return districtImages[districtName];
  }

  Future<Map<String, dynamic>?> geocodeLocation(String query) async {
    final encodedQuery = Uri.encodeComponent('$query, Zanzibar, Tanzania');
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=5&countrycodes=tz');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'SmartGeoApp/1.0', 'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) return results[0] as Map<String, dynamic>;
      }
    } catch (e) {}
    return null;
  }

  Future<District?> findNearestDistrict(double lat, double lng) async {
    try {
      final districts = await getDistricts();
      if (districts.isEmpty) return null;
      District? nearest;
      double minDistance = double.infinity;
      for (final district in districts) {
        final distance = _calculateDistance(lat, lng, district.latitude, district.longitude);
        if (distance < minDistance) { minDistance = distance; nearest = district; }
      }
      return nearest;
    } catch (e) { return null; }
  }

  Future<bool> toggleFavorite(int districtId) async {
    final token = await AuthService().getToken();
    if (token == null) return false;
    final response = await http.post(Uri.parse('$baseUrl/favorites/'), headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}, body: json.encode({'district_id': districtId}));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['is_favorite'] ?? false;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final token = await AuthService().getToken();
    if (token == null) return [];
    final response = await http.get(Uri.parse('$baseUrl/favorites/'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data.cast<Map<String, dynamic>>();
      if (data is Map && data.containsKey('results')) return (data['results'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> sendMessage(String subject, String body) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Not logged in');
    final response = await http.post(Uri.parse('$baseUrl/messages/'), headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}, body: json.encode({'subject': subject, 'body': body}));
    if (response.statusCode != 200) throw Exception('Failed to send message');
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) => degree * pi / 180;
}