import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';

class AdminMessages extends StatefulWidget {
  const AdminMessages({super.key});

  @override
  State<AdminMessages> createState() => _AdminMessagesState();
}

class _AdminMessagesState extends State<AdminMessages> {
  static const String baseUrl = 'http://10.126.217.239:8000/api';
  List<dynamic> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/messages/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() {
        _messages = json.decode(response.body) is List ? json.decode(response.body) : [];
        _loading = false;
      });
    }
  }

  Future<void> _reply(int messageId) async {
    final controller = TextEditingController();
    final reply = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Type reply...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Send')),
        ],
      ),
    );

    if (reply == null || reply.isEmpty) return;

    final token = await AuthService().getToken();
    await http.post(
      Uri.parse('$baseUrl/messages/$messageId/reply/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'body': reply}),
    );
    _loadMessages();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply sent!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _loading
        ? const Center(child: CircularProgressIndicator())
        : _messages.isEmpty
            ? const Center(child: Text('No messages'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, size: 20, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(msg['sender_name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text(msg['created_at']?.toString().substring(0, 10) ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(msg['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                          const SizedBox(height: 6),
                          Text(msg['body'] ?? '', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _reply(msg['id']),
                                icon: const Icon(Icons.reply, size: 18),
                                label: const Text('Reply'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}