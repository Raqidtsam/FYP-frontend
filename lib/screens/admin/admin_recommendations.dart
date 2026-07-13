import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminRecommendations extends StatefulWidget {
  const AdminRecommendations({super.key});

  @override
  State<AdminRecommendations> createState() => _AdminRecommendationsState();
}

class _AdminRecommendationsState extends State<AdminRecommendations> {
  final AdminService _adminService = AdminService();
  List<dynamic> _recommendations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final recs = await _adminService.getRecommendations();
      setState(() {
        _recommendations = recs;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _getScoreColor(dynamic score) {
    double s = double.tryParse(score.toString()) ?? 0;
    if (s >= 80) return Colors.green;
    if (s >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final rec = _recommendations[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getScoreColor(rec['score']),
                    child: Text('${rec['score']}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  title: Text(rec['sector__name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('${rec['district__name']} • ${rec['reason'] ?? ''}'),
                ),
              );
            },
          );
  }
}