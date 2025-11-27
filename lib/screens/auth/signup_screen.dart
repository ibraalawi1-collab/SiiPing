import 'package:flutter/material.dart';
import 'package:siiping/l10n/app_localizations.dart';
import 'package:siiping/services/auth_service.dart';
import 'package:siiping/screens/main_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _agreedToTerms = false;
  bool _isAgeVerified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.signUpTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Compliance: EULA Checkbox
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.agreeToTerms,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Compliance: Age Gate Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isAgeVerified,
                  onChanged: (value) {
                    setState(() {
                      _isAgeVerified = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.confirmAge,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: (_agreedToTerms && _isAgeVerified)
                  ? () async {
                      try {
                        final authService = AuthService();
                        await authService.signInWithGoogle();
                        if (context.mounted) {
                          // Navigate to Main Scaffold or Profile
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScaffold()),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login Failed: $e')),
                          );
                        }
                      }
                    }
                  : null, // Disable button if terms/age not agreed
              icon: const Icon(Icons.login),
              label: Text(AppLocalizations.of(context)!.googleSignInButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
