import 'package:flutter/material.dart';

class PasswordStrengthWidget extends StatelessWidget {
  final String password;

  const PasswordStrengthWidget({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = _checkStrength(password);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Strength bar
        Row(
          children: [
            _buildBar(0, strength),
            const SizedBox(width: 4),
            _buildBar(1, strength),
            const SizedBox(width: 4),
            _buildBar(2, strength),
            const SizedBox(width: 4),
            _buildBar(3, strength),
            const SizedBox(width: 8),
            Text(
              _getStrengthText(strength),
              style: TextStyle(
                color: _getStrengthColor(strength),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Requirements
        _buildRequirement('At least 8 characters', password.length >= 8),
        _buildRequirement('Uppercase letter (A-Z)', RegExp(r'[A-Z]').hasMatch(password)),
        _buildRequirement('Lowercase letter (a-z)', RegExp(r'[a-z]').hasMatch(password)),
        _buildRequirement('Number (0-9)', RegExp(r'[0-9]').hasMatch(password)),
        _buildRequirement('Special character (!@#\$%^&*)', RegExp(r'[!@#$%^&*(),.?\":{}|<>_\-+=~`\[\];/\\]').hasMatch(password)),
      ],
    );
  }

  int _checkStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?\":{}|<>_\-+=~`\[\];/\\]').hasMatch(password)) score++;
    
    if (score <= 2) return 1; // Weak
    if (score <= 3) return 2; // Fair
    if (score <= 4) return 3; // Good
    return 4; // Strong
  }

  Widget _buildBar(int index, int strength) {
    Color color;
    if (index < strength) {
      color = _getStrengthColor(strength);
    } else {
      color = Colors.grey.shade300;
    }
    
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.amber;
      case 4: return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 1: return 'Weak';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Strong';
      default: return '';
    }
  }

  Widget _buildRequirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: met ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: met ? Colors.green.shade700 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}