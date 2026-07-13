import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DistrictDetailScreen extends StatefulWidget {
  final int districtId;
  final String districtName;

  const DistrictDetailScreen({
    super.key,
    required this.districtId,
    required this.districtName,
  });

  @override
  State<DistrictDetailScreen> createState() => _DistrictDetailScreenState();
}

class _DistrictDetailScreenState extends State<DistrictDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _district;
  String? _districtImage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final data = await _apiService.getDistrictDetail(widget.districtId);
      final image = await _apiService.getDistrictImage(widget.districtName);
      setState(() {
        _district = data;
        _districtImage = image;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _getDominanceColor(String dominance) {
    switch (dominance) {
      case 'High':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.red.shade300;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String category) {
    switch (category.toLowerCase()) {
      case 'utalii':
        return Icons.beach_access;
      case 'uvuvi':
        return Icons.water;
      case 'kilimo':
        return Icons.agriculture;
      case 'biashara':
        return Icons.store;
      case 'ujenzi':
        return Icons.construction;
      default:
        return Icons.business;
    }
  }

  Color _getActivityColor(String category) {
    switch (category.toLowerCase()) {
      case 'utalii':
        return Colors.blue;
      case 'uvuvi':
        return Colors.teal;
      case 'kilimo':
        return Colors.green;
      case 'biashara':
        return Colors.orange;
      case 'ujenzi':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _district == null
              ? const Center(child: Text('Failed to load district details'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 220,
                      pinned: true,
                      backgroundColor: Colors.green.shade700,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          _district!['name'] ?? widget.districtName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        background: _districtImage != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    _districtImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.green.shade700, Colors.green.shade400],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.5)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green.shade700, Colors.green.shade400],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.location_on, size: 16, color: Colors.green.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_district!['region'] ?? ''}, ${_district!['island'] ?? ''}',
                                        style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    _buildCoordinateBox('Latitude', '${_district!['latitude']}', Icons.swap_vert),
                                    const SizedBox(width: 12),
                                    _buildCoordinateBox('Longitude', '${_district!['longitude']}', Icons.swap_horiz),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Economic Activities',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${(_district!['activities'] as List?)?.length ?? 0} activities',
                                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_district!['activities'] != null && (_district!['activities'] as List).isNotEmpty)
                              ...(_district!['activities'] as List).map((activity) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _getActivityColor(activity['category']).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _getActivityColor(activity['category']).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getActivityIcon(activity['category']),
                                        color: _getActivityColor(activity['category']),
                                        size: 24,
                                      ),
                                    ),
                                    title: Text(
                                      activity['name'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          activity['description'] ?? '',
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getDominanceColor(activity['dominance']).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                activity['dominance'] ?? '',
                                                style: TextStyle(
                                                  color: _getDominanceColor(activity['dominance']),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getActivityColor(activity['category']).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                activity['category'] ?? '',
                                                style: TextStyle(
                                                  color: _getActivityColor(activity['category']),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                            else
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(30),
                                  child: Column(
                                    children: [
                                      Icon(Icons.info_outline, size: 50, color: Colors.grey.shade400),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No economic activities recorded',
                                        style: TextStyle(color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCoordinateBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}