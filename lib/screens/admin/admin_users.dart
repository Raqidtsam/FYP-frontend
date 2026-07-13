import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  final AdminService _adminService = AdminService();
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _adminService.getUsers();
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user['is_admin'] == true ? Colors.red.shade100 : Colors.blue.shade100,
                    child: Text(user['full_name'][0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(user['full_name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('${user['email']} • ${user['nationality']}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text(user['is_active'] == true ? 'Deactivate' : 'Activate'),
                        onTap: () async {
                          await _adminService.toggleUserStatus(user['id']);
                          _loadUsers();
                        },
                      ),
                      PopupMenuItem(
                        child: Text(user['is_admin'] == true ? 'Remove Admin' : 'Make Admin'),
                        onTap: () async {
                          await _adminService.toggleAdminStatus(user['id']);
                          _loadUsers();
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        onTap: () async {
                          await _adminService.deleteUser(user['id']);
                          _loadUsers();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}