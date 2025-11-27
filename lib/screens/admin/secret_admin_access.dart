import 'package:flutter/material.dart';
import 'package:siiping/screens/admin/admin_dashboard_screen.dart';

/// Secret Admin Access Screen
/// Navigate to this screen by typing the secret code
class SecretAdminAccess extends StatefulWidget {
  const SecretAdminAccess({super.key});

  @override
  State<SecretAdminAccess> createState() => _SecretAdminAccessState();
}

class _SecretAdminAccessState extends State<SecretAdminAccess> {
  final _codeController = TextEditingController();
  final _secretCode = 'NIXEN2025'; // غيّر هذا الكود لكود سري خاص بك

  void _checkCode() {
    if (_codeController.text.trim() == _secretCode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboardScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كود خاطئ'),
          backgroundColor: Colors.red,
        ),
      );
      _codeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeController,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: '• • • • • • • •',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _checkCode(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text('دخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
