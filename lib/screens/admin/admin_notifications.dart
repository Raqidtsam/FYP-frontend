import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminNotifications extends StatefulWidget {
  const AdminNotifications({super.key});

  @override
  State<AdminNotifications> createState() => _AdminNotificationsState();
}

class _AdminNotificationsState extends State<AdminNotifications> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _sending = false;

  Future<void> _sendNotification() async {
    if (_bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final adminService = AdminService();
      final result = await adminService.sendNotification(
        _titleController.text.trim().isEmpty ? 'Smart Geo Investment' : _titleController.text.trim(),
        _bodyController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Sent to ${result['total_tokens']} devices (${result['success']} success)'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Push Notifications'), backgroundColor: Colors.grey.shade900, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title (optional)',
                hintText: 'Smart Geo Investment',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Message *',
                hintText: 'Enter notification message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _sendNotification,
                icon: _sending ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Icon(Icons.notifications_active),
                label: Text(_sending ? 'Sending...' : 'Send to All Users'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}