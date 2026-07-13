import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryItem {
  final String query;
  final String locationName;
  final double latitude;
  final double longitude;
  final String districtName;
  final int districtId;
  final DateTime timestamp;

  SearchHistoryItem({
    required this.query,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.districtName,
    required this.districtId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'districtName': districtName,
        'districtId': districtId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      query: json['query'] ?? '',
      locationName: json['locationName'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      districtName: json['districtName'] ?? '',
      districtId: json['districtId'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class SearchHistoryService {
  static const String _key = 'search_history';
  static const int _maxItems = 20;

  Future<List<SearchHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    
    return data
        .map((e) => SearchHistoryItem.fromJson(json.decode(e)))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addSearch(SearchHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getHistory();

    // Remove duplicate
    items.removeWhere((i) => i.query.toLowerCase() == item.query.toLowerCase());

    // Add to beginning
    items.insert(0, item);

    // Limit to max items
    if (items.length > _maxItems) {
      items.removeRange(_maxItems, items.length);
    }

    // Save
    final data = items.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_key, data);
  }

  Future<void> deleteItem(int index) async {
    final items = await getHistory();
    if (index < items.length) {
      items.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      final data = items.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList(_key, data);
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}