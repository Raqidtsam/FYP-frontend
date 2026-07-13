import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import '../widgets/password_strength_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _contactController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _selectedNationality = '';
  String _selectedFlag = '';
  String _selectedCountryCode = '+255';

  final List<Map<String, String>> _countryCodes = [
    {'code': '+255', 'flag': '🇹🇿', 'name': 'Tanzania'},
    {'code': '+254', 'flag': '🇰🇪', 'name': 'Kenya'},
    {'code': '+256', 'flag': '🇺🇬', 'name': 'Uganda'},
    {'code': '+250', 'flag': '🇷🇼', 'name': 'Rwanda'},
    {'code': '+257', 'flag': '🇧🇮', 'name': 'Burundi'},
    {'code': '+27', 'flag': '🇿🇦', 'name': 'South Africa'},
    {'code': '+234', 'flag': '🇳🇬', 'name': 'Nigeria'},
    {'code': '+233', 'flag': '🇬🇭', 'name': 'Ghana'},
    {'code': '+251', 'flag': '🇪🇹', 'name': 'Ethiopia'},
    {'code': '+20', 'flag': '🇪🇬', 'name': 'Egypt'},
    {'code': '+212', 'flag': '🇲🇦', 'name': 'Morocco'},
    {'code': '+213', 'flag': '🇩🇿', 'name': 'Algeria'},
    {'code': '+216', 'flag': '🇹🇳', 'name': 'Tunisia'},
    {'code': '+218', 'flag': '🇱🇾', 'name': 'Libya'},
    {'code': '+249', 'flag': '🇸🇩', 'name': 'Sudan'},
    {'code': '+252', 'flag': '🇸🇴', 'name': 'Somalia'},
    {'code': '+243', 'flag': '🇨🇩', 'name': 'DR Congo'},
    {'code': '+260', 'flag': '🇿🇲', 'name': 'Zambia'},
    {'code': '+263', 'flag': '🇿🇼', 'name': 'Zimbabwe'},
    {'code': '+265', 'flag': '🇲🇼', 'name': 'Malawi'},
    {'code': '+258', 'flag': '🇲🇿', 'name': 'Mozambique'},
    {'code': '+244', 'flag': '🇦🇴', 'name': 'Angola'},
    {'code': '+264', 'flag': '🇳🇦', 'name': 'Namibia'},
    {'code': '+267', 'flag': '🇧🇼', 'name': 'Botswana'},
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
    {'code': '+86', 'flag': '🇨🇳', 'name': 'China'},
    {'code': '+81', 'flag': '🇯🇵', 'name': 'Japan'},
    {'code': '+82', 'flag': '🇰🇷', 'name': 'South Korea'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
    {'code': '+974', 'flag': '🇶🇦', 'name': 'Qatar'},
    {'code': '+966', 'flag': '🇸🇦', 'name': 'Saudi Arabia'},
    {'code': '+968', 'flag': '🇴🇲', 'name': 'Oman'},
    {'code': '+90', 'flag': '🇹🇷', 'name': 'Turkey'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'United Kingdom'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'United States/Canada'},
    {'code': '+49', 'flag': '🇩🇪', 'name': 'Germany'},
    {'code': '+33', 'flag': '🇫🇷', 'name': 'France'},
    {'code': '+39', 'flag': '🇮🇹', 'name': 'Italy'},
    {'code': '+34', 'flag': '🇪🇸', 'name': 'Spain'},
    {'code': '+31', 'flag': '🇳🇱', 'name': 'Netherlands'},
    {'code': '+46', 'flag': '🇸🇪', 'name': 'Sweden'},
    {'code': '+47', 'flag': '🇳🇴', 'name': 'Norway'},
    {'code': '+45', 'flag': '🇩🇰', 'name': 'Denmark'},
    {'code': '+41', 'flag': '🇨🇭', 'name': 'Switzerland'},
    {'code': '+32', 'flag': '🇧🇪', 'name': 'Belgium'},
    {'code': '+351', 'flag': '🇵🇹', 'name': 'Portugal'},
    {'code': '+7', 'flag': '🇷🇺', 'name': 'Russia'},
    {'code': '+61', 'flag': '🇦🇺', 'name': 'Australia'},
    {'code': '+64', 'flag': '🇳🇿', 'name': 'New Zealand'},
    {'code': '+55', 'flag': '🇧🇷', 'name': 'Brazil'},
    {'code': '+54', 'flag': '🇦🇷', 'name': 'Argentina'},
    {'code': '+52', 'flag': '🇲🇽', 'name': 'Mexico'},
  ];

  final List<Map<String, String>> _countries = [
    {'name': 'Tanzania', 'flag': '🇹🇿'},
    {'name': 'Kenya', 'flag': '🇰🇪'},
    {'name': 'Uganda', 'flag': '🇺🇬'},
    {'name': 'Rwanda', 'flag': '🇷🇼'},
    {'name': 'Burundi', 'flag': '🇧🇮'},
    {'name': 'South Africa', 'flag': '🇿🇦'},
    {'name': 'Nigeria', 'flag': '🇳🇬'},
    {'name': 'Ghana', 'flag': '🇬🇭'},
    {'name': 'Ethiopia', 'flag': '🇪🇹'},
    {'name': 'Egypt', 'flag': '🇪🇬'},
    {'name': 'Morocco', 'flag': '🇲🇦'},
    {'name': 'Algeria', 'flag': '🇩🇿'},
    {'name': 'Tunisia', 'flag': '🇹🇳'},
    {'name': 'Libya', 'flag': '🇱🇾'},
    {'name': 'Sudan', 'flag': '🇸🇩'},
    {'name': 'Somalia', 'flag': '🇸🇴'},
    {'name': 'DR Congo', 'flag': '🇨🇩'},
    {'name': 'Zambia', 'flag': '🇿🇲'},
    {'name': 'Zimbabwe', 'flag': '🇿🇼'},
    {'name': 'Malawi', 'flag': '🇲🇼'},
    {'name': 'Mozambique', 'flag': '🇲🇿'},
    {'name': 'Angola', 'flag': '🇦🇴'},
    {'name': 'Namibia', 'flag': '🇳🇦'},
    {'name': 'Botswana', 'flag': '🇧🇼'},
    {'name': 'India', 'flag': '🇮🇳'},
    {'name': 'China', 'flag': '🇨🇳'},
    {'name': 'Japan', 'flag': '🇯🇵'},
    {'name': 'South Korea', 'flag': '🇰🇷'},
    {'name': 'United Arab Emirates', 'flag': '🇦🇪'},
    {'name': 'Qatar', 'flag': '🇶🇦'},
    {'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'name': 'Oman', 'flag': '🇴🇲'},
    {'name': 'Turkey', 'flag': '🇹🇷'},
    {'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'name': 'United States', 'flag': '🇺🇸'},
    {'name': 'Canada', 'flag': '🇨🇦'},
    {'name': 'Germany', 'flag': '🇩🇪'},
    {'name': 'France', 'flag': '🇫🇷'},
    {'name': 'Italy', 'flag': '🇮🇹'},
    {'name': 'Spain', 'flag': '🇪🇸'},
    {'name': 'Netherlands', 'flag': '🇳🇱'},
    {'name': 'Sweden', 'flag': '🇸🇪'},
    {'name': 'Norway', 'flag': '🇳🇴'},
    {'name': 'Denmark', 'flag': '🇩🇰'},
    {'name': 'Switzerland', 'flag': '🇨🇭'},
    {'name': 'Belgium', 'flag': '🇧🇪'},
    {'name': 'Portugal', 'flag': '🇵🇹'},
    {'name': 'Russia', 'flag': '🇷🇺'},
    {'name': 'Australia', 'flag': '🇦🇺'},
    {'name': 'New Zealand', 'flag': '🇳🇿'},
    {'name': 'Brazil', 'flag': '🇧🇷'},
    {'name': 'Argentina', 'flag': '🇦🇷'},
    {'name': 'Mexico', 'flag': '🇲🇽'},
    {'name': 'Other', 'flag': '🌍'},
  ];

  Map<String, Map<String, String>> get _nationalityToCode {
    final map = <String, Map<String, String>>{};
    for (final country in _countries) {
      final name = country['name']!;
      final codeEntry = _countryCodes.where((c) => c['name'] == name).firstOrNull;
      if (codeEntry != null) map[name] = codeEntry;
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  Future<void> _register() async {
    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      nationality: _selectedNationality,
      contact: '$_selectedCountryCode${_contactController.text.trim()}',
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (result['success']) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.person_add, size: 60, color: Colors.green),
                  const SizedBox(height: 8),
                  Text('Join Smart Geo Investment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                  const SizedBox(height: 4),
                  const Text('Create your account to get started'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Full Name *', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(hintText: 'e.g. John Doe', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),
            const Text('Email *', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'e.g. john@example.com', prefixIcon: const Icon(Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            const Text('Password *', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: '••••••••', prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: _obscurePassword,
            ),
            PasswordStrengthWidget(password: _passwordController.text),
            const SizedBox(height: 20),
            const Text('Confirm Password *', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                hintText: '••••••••', prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: _obscureConfirmPassword,
            ),
            const SizedBox(height: 20),
            const Text('Nationality', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade500), borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true, hint: const Text('Select your nationality'),
                  value: _selectedNationality.isNotEmpty ? _selectedNationality : null,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _countries.map((c) => DropdownMenuItem<String>(value: c['name'], child: Row(children: [Text(c['flag']!, style: const TextStyle(fontSize: 22)), const SizedBox(width: 12), Text(c['name']!)]))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedNationality = value!;
                      _selectedFlag = _countries.firstWhere((c) => c['name'] == value)['flag']!;
                      final codeEntry = _nationalityToCode[value];
                      if (codeEntry != null) _selectedCountryCode = codeEntry['code']!;
                    });
                  },
                ),
              ),
            ),
            if (_selectedNationality.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Text(_selectedFlag, style: const TextStyle(fontSize: 22)), const SizedBox(width: 8), Text(_selectedNationality, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500))]),
              ),
            ],
            const SizedBox(height: 20),
            const Text('Contact Number', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(children: [
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade500), borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountryCode, icon: const Icon(Icons.arrow_drop_down),
                    items: _countryCodes.map((code) => DropdownMenuItem<String>(value: code['code'], child: Row(mainAxisSize: MainAxisSize.min, children: [Text(code['flag']!, style: const TextStyle(fontSize: 20)), const SizedBox(width: 4), Text(code['code']!, style: const TextStyle(fontWeight: FontWeight.w500))]))).toList(),
                    onChanged: (value) => setState(() => _selectedCountryCode = value!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _contactController, decoration: InputDecoration(hintText: '712 345 678', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), keyboardType: TextInputType.phone)),
            ]),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.green.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create Account', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('Already have an account? Login'))),
          ],
        ),
      ),
    );
  }
}