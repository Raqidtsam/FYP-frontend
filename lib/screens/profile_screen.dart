import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? _userData;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;

  File? _imageFile;
  bool _removeImage = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _userService.getProfile();
      if (mounted) {
        setState(() {
          _userData = data;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _enableEditing() {
    _fullNameController.text = _userData?['full_name'] ?? '';
    _emailController.text = _userData?['email'] ?? '';
    _nationalityController.text = _userData?['nationality'] ?? '';
    _contactController.text = _userData?['contact'] ?? '';
    _passwordController.clear();
    _imageFile = null;
    _removeImage = false;
    _obscureNewPassword = true;
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    setState(() => _editing = false);
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_imageFile != null || (_userData?['profile_picture'] != null && !_removeImage))
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _imageFile = null;
                        _removeImage = true;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _removeImage = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);

    final result = await _userService.updateProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      nationality: _nationalityController.text.trim(),
      contact: _contactController.text.trim(),
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      profilePicturePath: _removeImage ? 'remove' : _imageFile?.path,
    );

    setState(() => _saving = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _editing = false);
      _loadProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _nationalityController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit Profile' : 'Profile'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _enableEditing,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('Failed to load profile'))
              : _editing
                  ? _buildEditMode()
                  : _buildViewMode(),
    );
  }

  Widget _buildViewMode() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ImageProvider? bgImage;
    if (_userData?['profile_picture'] != null) {
      bgImage = NetworkImage(_userData!['profile_picture']);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.green.shade100,
            backgroundImage: bgImage,
            child: bgImage == null
                ? Icon(Icons.person, size: 60, color: Colors.green.shade700)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _userData?['full_name'] ?? 'User',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData?['email'] ?? '',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildInfoTile(Icons.email, 'Email', _userData?['email'] ?? '-'),
                const Divider(height: 1),
                _buildInfoTile(Icons.flag, 'Nationality', _userData?['nationality'] ?? '-'),
                const Divider(height: 1),
                _buildInfoTile(Icons.phone, 'Contact', _userData?['contact'] ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Dark Mode Toggle
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: Text(themeProvider.isDarkMode ? 'Switch to Light' : 'Switch to Dark'),
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: themeProvider.isDarkMode ? Colors.amber : Colors.grey,
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    ImageProvider? bgImage;
    if (_removeImage) {
      bgImage = null;
    } else if (_imageFile != null) {
      bgImage = FileImage(_imageFile!);
    } else if (_userData?['profile_picture'] != null) {
      bgImage = NetworkImage(_userData!['profile_picture']);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Center(
            child: GestureDetector(
              onTap: _showImagePickerOptions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green.shade100,
                    backgroundImage: bgImage,
                    child: bgImage == null
                        ? Icon(Icons.person, size: 60, color: Colors.green.shade700)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _showImagePickerOptions,
            child: const Text('Change Profile Photo'),
          ),
          const SizedBox(height: 20),
          const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _fullNameController,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          const Text('Email', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          const Text('Nationality', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _nationalityController,
            decoration: InputDecoration(
              hintText: 'Enter your nationality',
              prefixIcon: const Icon(Icons.flag),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Contact', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _contactController,
            decoration: InputDecoration(
              hintText: 'Enter your phone number',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          const Text('New Password (optional)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Leave blank to keep current',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            obscureText: _obscureNewPassword,
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Save Changes', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }
}