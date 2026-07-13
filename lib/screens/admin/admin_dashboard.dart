import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _adminService.getDashboard();
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = _data?['stats'] ?? {};

    return _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.admin_panel_settings, color: Colors.blue, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Admin Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(
                          'Smart Geo Investment System',
                          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text('Active', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Stats Cards
                Row(
                  children: [
                    _buildStatCard('Total Users', '${stats['total_users'] ?? 0}', Icons.people, Colors.blue, '+12%'),
                    const SizedBox(width: 14),
                    _buildStatCard('Districts', '${stats['total_districts'] ?? 0}', Icons.map, Colors.green, 'All'),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatCard('Regions', '${stats['total_regions'] ?? 0}', Icons.public, Colors.orange, 'Active'),
                    const SizedBox(width: 14),
                    _buildStatCard('Sectors', '${stats['total_sectors'] ?? 0}', Icons.business, Colors.purple, 'Active'),
                  ],
                ),
                const SizedBox(height: 14),
                _buildStatCard('AI Recs', '${stats['total_recommendations'] ?? 0}', Icons.auto_awesome, Colors.teal, 'Generated', fullWidth: true),

                const SizedBox(height: 28),

                // Quick Actions Section
                Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildActionCard(Icons.people, 'Users', Colors.blue, () {}),
                    const SizedBox(width: 14),
                    _buildActionCard(Icons.map, 'Districts', Colors.green, () {}),
                    const SizedBox(width: 14),
                    _buildActionCard(Icons.auto_awesome, 'AI Recs', Colors.teal, () {}),
                    const SizedBox(width: 14),
                    _buildActionCard(Icons.settings, 'Settings', Colors.grey, () {}),
                  ],
                ),
                const SizedBox(height: 28),

                // Recent Users
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    TextButton(onPressed: () {}, child: const Text('View All')),
                  ],
                ),
                const SizedBox(height: 12),
                if (_data?['recent_users'] != null)
                  ...(_data!['recent_users'] as List).map<Widget>((user) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.blue.shade50,
                          child: Text(
                            (user['full_name'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        title: Text(user['full_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(user['email'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user['nationality'] ?? '',
                            style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    );
                  }),
                if (_data?['recent_users'] == null || (_data!['recent_users'] as List).isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text('No users registered yet', style: TextStyle(color: Colors.grey.shade500)),
                    ),
                  ),
              ],
            ),
          );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String badge, {bool fullWidth = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return fullWidth
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                    Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(badge, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          )
        : Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(badge, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ),
          );
  }

  Widget _buildActionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}