import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminDistricts extends StatefulWidget {
  const AdminDistricts({super.key});

  @override
  State<AdminDistricts> createState() => _AdminDistrictsState();
}

class _AdminDistrictsState extends State<AdminDistricts> {
  final AdminService _adminService = AdminService();
  List<dynamic> _districts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      final districts = await _adminService.getDistricts();
      setState(() {
        _districts = districts;
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
            itemCount: _districts.length,
            itemBuilder: (context, index) {
              final d = _districts[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.green),
                  title: Text(d['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('${d['region__name']} • ${d['region__island']}'),
                  trailing: Text('${d['latitude']}, ${d['longitude']}'),
                ),
              );
            },
          );
  }
}