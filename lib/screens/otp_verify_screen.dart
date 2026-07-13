import 'package:flutter/material.dart';

class OTPVerifyScreen extends StatefulWidget {
  final String email;
  final String title;
  final String subtitle;
  final Future<Map<String, dynamic>> Function(String otp) onVerify;

  const OTPVerifyScreen({
    super.key,
    required this.email,
    required this.title,
    required this.subtitle,
    required this.onVerify,
  });

  @override
  State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;

  Future<void> _verify() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP code')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await widget.onVerify(_otpController.text.trim());

    setState(() => _loading = false);

    if (!mounted) return;

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Verification failed')),
      );
    }
    // Success is handled by the callback (navigation)
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.email, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Sent to ${widget.email}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'OTP Code',
                hintText: 'Enter 6-digit code',
                prefixIcon: const Icon(Icons.pin),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, letterSpacing: 8),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}