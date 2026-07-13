import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminRecommendationsControl extends StatefulWidget {
  const AdminRecommendationsControl({super.key});

  @override
  State<AdminRecommendationsControl> createState() => _AdminRecommendationsControlState();
}

class _AdminRecommendationsControlState extends State<AdminRecommendationsControl> {
  final AdminService _adminService = AdminService();
  List<dynamic> _recommendations = [];
  List<dynamic> _sectors = [];
  List<dynamic> _districts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final recs = await _adminService.getRecommendations();
      final sectors = await _adminService.getSectors();
      final districts = await _adminService.getDistricts();
      setState(() {
        _recommendations = recs;
        _sectors = sectors;
        _districts = districts;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _generateRecommendations() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await _adminService.generateRecommendations();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recommendations generated!'), backgroundColor: Colors.green),
    );
    _loadData();
  }

  void _showAddDialog() {
    int? selectedDistrict;
    int? selectedSector;
    double score = 50;
    String reason = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Recommendation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'District'),
                items: _districts.map((d) => DropdownMenuItem(value: d['id'] as int, child: Text(d['name']))).toList(),
                onChanged: (v) => setDialogState(() => selectedDistrict = v),
              ),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Sector'),
                items: _sectors.map((s) => DropdownMenuItem(value: s['id'] as int, child: Text(s['name']))).toList(),
                onChanged: (v) => setDialogState(() => selectedSector = v),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Score (0-100)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => score = double.tryParse(v) ?? 50,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Reason'),
                onChanged: (v) => reason = v,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedDistrict != null && selectedSector != null) {
                  await _adminService.addRecommendation(selectedDistrict!, selectedSector!, score, reason);
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(dynamic score) {
    double s = double.tryParse(score.toString()) ?? 0;
    if (s >= 80) return Colors.green;
    if (s >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generateRecommendations,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate AI Recommendations'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Manual'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ),
                Text('Total: ${_recommendations.length} recommendations', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final rec = _recommendations[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getScoreColor(rec['score']),
                            child: Text('${rec['score']}%', style: const TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                          title: Text(rec['sector__name'] ?? ''),
                          subtitle: Text('${rec['district__name']} • ${rec['reason'] ?? ''}'),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                onTap: () async {
                                  await _adminService.deleteRecommendation(rec['id']);
                                  _loadData();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}