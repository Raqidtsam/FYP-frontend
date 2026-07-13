import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MapScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.green.shade700,
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(_currentIndex == 0 ? Icons.dashboard_rounded : Icons.dashboard_outlined),
                activeIcon: const Icon(Icons.dashboard_rounded, size: 26),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(_currentIndex == 1 ? Icons.map_rounded : Icons.map_outlined),
                activeIcon: const Icon(Icons.map_rounded, size: 26),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(_currentIndex == 2 ? Icons.search_rounded : Icons.search_outlined),
                activeIcon: const Icon(Icons.search_rounded, size: 26),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(_currentIndex == 3 ? Icons.person_rounded : Icons.person_outlined),
                activeIcon: const Icon(Icons.person_rounded, size: 26),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}