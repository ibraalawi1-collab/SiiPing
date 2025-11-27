import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siiping/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.privacyPolicyTitle),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('PRIVACY_POLICY_DRAFT.md'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                snapshot.data!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading policy'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
