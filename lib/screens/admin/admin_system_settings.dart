import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminSystemSettings extends StatefulWidget {
  const AdminSystemSettings({super.key});

  @override
  State<AdminSystemSettings> createState() => _AdminSystemSettingsState();
}

class _AdminSystemSettingsState extends State<AdminSystemSettings> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _systemInfo;
  bool _loading = true;
  bool _backingUp = false;
  bool _testingEmail = false;

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    try {
      final info = await _adminService.getSystemInfo();
      if (mounted) {
        setState(() {
          _systemInfo = info;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _backupDatabase() async {
    setState(() => _backingUp = true);
    try {
      await _adminService.backupDatabase();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Backup completed successfully!'), backgroundColor: Color(0xFF10B981)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Backup failed: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _backingUp = false);
  }

  Future<void> _testEmail() async {
    final controller = TextEditingController(text: 'admin@smartgeo.com');
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🧪 Test Email'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Email address',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Send Test'),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;

    setState(() => _testingEmail = true);
    try {
      final result = await _adminService.testEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${result['message'] ?? 'Email sent!'}'), backgroundColor: const Color(0xFF10B981)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _testingEmail = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                          : [Colors.blue.shade50, Colors.purple.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.settings, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('System Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(
                            'Manage configuration & maintenance',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // System Information
                _buildSectionTitle('📊 System Information', isDark),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile('App Name', _systemInfo?['app_name'] ?? 'N/A', Icons.info_outline, const Color(0xFF6366F1)),
                      _buildDivider(isDark),
                      _buildInfoTile('Version', _systemInfo?['version'] ?? 'N/A', Icons.code, const Color(0xFF8B5CF6)),
                      _buildDivider(isDark),
                      _buildInfoTile('Total Users', '${_systemInfo?['total_users'] ?? 0}', Icons.people, const Color(0xFF3B82F6)),
                      _buildDivider(isDark),
                      _buildInfoTile('Total Districts', '${_systemInfo?['total_districts'] ?? 0}', Icons.map, const Color(0xFF10B981)),
                      _buildDivider(isDark),
                      _buildInfoTile('AI Recommendations', '${_systemInfo?['total_recommendations'] ?? 0}', Icons.auto_awesome, const Color(0xFF06B6D4)),
                      _buildDivider(isDark),
                      _buildInfoTile('Database Size', _systemInfo?['database_size'] ?? 'N/A', Icons.storage, const Color(0xFFF59E0B)),
                      _buildDivider(isDark),
                      _buildInfoTile('Server Time', _formatDate(_systemInfo?['server_time']), Icons.access_time, const Color(0xFF6B7280)),
                      _buildDivider(isDark),
                      _buildInfoTile('Debug Mode', _systemInfo?['debug_mode'] == true ? '🟢 ON' : '🔴 OFF', Icons.toggle_on, _systemInfo?['debug_mode'] == true ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Maintenance Actions
                _buildSectionTitle('🔧 Maintenance', isDark),
                const SizedBox(height: 14),
                
                // Backup Database
                _buildActionCard(
                  icon: Icons.backup,
                  title: 'Backup Database',
                  subtitle: 'Create a full database backup',
                  color: const Color(0xFF6366F1),
                  isLoading: _backingUp,
                  onTap: _backupDatabase,
                ),
                const SizedBox(height: 12),

                // Test Email
                _buildActionCard(
                  icon: Icons.email,
                  title: 'Test Email',
                  subtitle: 'Verify email configuration',
                  color: const Color(0xFF10B981),
                  isLoading: _testingEmail,
                  onTap: _testEmail,
                ),
                const SizedBox(height: 12),

                // Refresh System Info
                _buildActionCard(
                  icon: Icons.refresh,
                  title: 'Refresh System Info',
                  subtitle: 'Reload system information',
                  color: const Color(0xFFF59E0B),
                  isLoading: false,
                  onTap: _loadSystemInfo,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, indent: 18, endIndent: 18, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200);
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: isLoading
                  ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                  : Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_rounded, color: color, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate.substring(0, 19);
    }
  }
}