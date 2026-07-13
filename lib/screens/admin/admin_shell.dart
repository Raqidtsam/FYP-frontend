import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'admin_dashboard.dart';
import 'admin_users.dart';
import 'admin_districts.dart';
import 'admin_recommendations_control.dart';
import 'admin_notifications.dart';
import 'admin_messages.dart';
import 'admin_system_settings.dart';
import '../login_screen.dart';
import '../../services/auth_service.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;
  final String _adminName = 'Admin';

  final List<Widget> _pages = const [
    AdminDashboard(),
    AdminUsers(),
    AdminDistricts(),
    AdminRecommendationsControl(),
    AdminNotifications(),
    AdminMessages(),
    AdminSystemSettings(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade900,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(_adminName, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade900,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(_adminName, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
            _buildDrawerItem(Icons.people, 'Users', 1),
            _buildDrawerItem(Icons.map, 'Districts', 2),
            _buildDrawerItem(Icons.auto_awesome, 'AI Recs', 3),
            _buildDrawerItem(Icons.notifications, 'Notifications', 4),
            _buildDrawerItem(Icons.message, 'Messages', 5),
            _buildDrawerItem(Icons.settings, 'Settings', 6),
            const Divider(color: Colors.grey),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ListTile(
                  leading: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.grey),
                  title: Text(themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode', style: const TextStyle(color: Colors.grey)),
                  onTap: () => themeProvider.toggleTheme(),
                );
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await AuthService().logout();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: _currentIndex == index ? Colors.blue : Colors.grey),
      title: Text(title, style: TextStyle(color: _currentIndex == index ? Colors.blue : Colors.grey)),
      selected: _currentIndex == index,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}