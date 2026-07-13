import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../models/district.dart';
import 'district_detail_screen.dart';
import 'messages_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<District> _districts = [];
  int _totalDistricts = 0;
  int _totalRegions = 0;
  bool _loading = true;
  String _userName = 'User';
  String? _profilePic;

  final List<Map<String, dynamic>> _quickStats = [
    {'icon': Icons.public, 'label': 'Regions', 'value': '5', 'color': const Color(0xFF6366F1), 'gradient': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]},
    {'icon': Icons.location_city, 'label': 'Districts', 'value': '10', 'color': const Color(0xFFF59E0B), 'gradient': [const Color(0xFFF59E0B), const Color(0xFFF97316)]},
    {'icon': Icons.beach_access, 'label': 'Unguja', 'value': '3', 'color': const Color(0xFF06B6D4), 'gradient': [const Color(0xFF06B6D4), const Color(0xFF0EA5E9)]},
    {'icon': Icons.nature, 'label': 'Pemba', 'value': '2', 'color': const Color(0xFF10B981), 'gradient': [const Color(0xFF10B981), const Color(0xFF34D399)]},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      final user = json.decode(userData);
      setState(() {
        _userName = user['full_name'] ?? 'User';
      });
    }
    try {
      final data = await UserService().getProfile();
      if (data != null) {
        setState(() {
          _profilePic = data['profile_picture'];
        });
      }
    } catch (e) {}
  }

  Future<void> _loadData() async {
    try {
      final districts = await _apiService.getDistricts();
      final regions = <int>{};
      for (var d in districts) {
        regions.add(d.regionId);
      }
      setState(() {
        _districts = districts;
        _totalDistricts = districts.length;
        _totalRegions = regions.length;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)] : [Colors.green.shade50, Colors.blue.shade50],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.green, Colors.teal])),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                              backgroundImage: _profilePic != null ? NetworkImage(_profilePic!) : null,
                              child: _profilePic == null ? Text(_userName[0].toUpperCase(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green)) : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hello, $_userName', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                                const SizedBox(height: 4),
                                Text('Find your next investment today ✨', style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(children: [_buildDecorativeStatCard(_quickStats[0], isDark, true), const SizedBox(width: 14), _buildDecorativeStatCard(_quickStats[1], isDark, false)]),
                    const SizedBox(height: 14),
                    Row(children: [_buildDecorativeStatCard(_quickStats[2], isDark, false), const SizedBox(width: 14), _buildDecorativeStatCard(_quickStats[3], isDark, true)]),
                    const SizedBox(height: 28),
                    Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildActionCard(Icons.message, 'Contact', Colors.purple, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
                        }),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Container(width: 4, height: 24, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 12),
                        Text('Explore Districts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        const Spacer(),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text('$_totalDistricts locations', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._districts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final d = entry.value;
                      final colors = [
                        [const Color(0xFF6366F1), const Color(0xFF8B5CF6)], [const Color(0xFF06B6D4), const Color(0xFF0EA5E9)],
                        [const Color(0xFF10B981), const Color(0xFF34D399)], [const Color(0xFFF59E0B), const Color(0xFFF97316)],
                        [const Color(0xFFEF4444), const Color(0xFFF87171)], [const Color(0xFFEC4899), const Color(0xFFF472B6)],
                        [const Color(0xFF6366F1), const Color(0xFF818CF8)], [const Color(0xFF14B8A6), const Color(0xFF2DD4BF)],
                        [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)], [const Color(0xFFF97316), const Color(0xFFFB923C)],
                      ];
                      final cardColors = colors[index % colors.length];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(colors: [cardColors[0].withValues(alpha: 0.06), cardColors[1].withValues(alpha: 0.04)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          border: Border.all(color: cardColors[0].withValues(alpha: 0.2)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          leading: Container(width: 48, height: 48, decoration: BoxDecoration(gradient: LinearGradient(colors: cardColors), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.location_on, color: Colors.white, size: 24)),
                          title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          subtitle: Text('Tap to explore', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          trailing: Container(width: 38, height: 38, decoration: BoxDecoration(color: cardColors[0].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.arrow_forward_rounded, color: cardColors[0], size: 20)),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DistrictDetailScreen(districtId: d.id, districtName: d.name))),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDecorativeStatCard(Map<String, dynamic> stat, bool isDark, bool isHighlighted) {
    final colors = stat['gradient'] as List<Color>;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: isHighlighted ? colors : [isDark ? const Color(0xFF1E1E1E) : Colors.white, isDark ? const Color(0xFF1E1E1E) : Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          border: isHighlighted ? null : Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          boxShadow: isHighlighted ? [BoxShadow(color: colors[0].withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 6))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isHighlighted ? Colors.white.withValues(alpha: 0.2) : colors[0].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(stat['icon'] as IconData, color: isHighlighted ? Colors.white : colors[0], size: 22)),
            const SizedBox(height: 16),
            Text(stat['value'] as String, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: isHighlighted ? Colors.white : (isDark ? Colors.white : colors[0]))),
            const SizedBox(height: 4),
            Text(stat['label'] as String, style: TextStyle(fontSize: 13, color: isHighlighted ? Colors.white70 : Colors.grey.shade500, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
        child: Column(children: [Icon(icon, color: color, size: 28), const SizedBox(height: 8), Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: isDark ? Colors.white70 : Colors.black87))]),
      ),
    );
  }
}