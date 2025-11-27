import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:siiping/l10n/app_localizations.dart';
import 'package:siiping/services/notification_service.dart';
import 'package:siiping/theme/app_theme.dart';
import 'package:siiping/screens/main_scaffold.dart';
import 'package:siiping/providers/language_provider.dart';

import 'package:siiping/services/sound_service.dart';
import 'package:siiping/screens/auth/auth_screen.dart';
// import 'package:siiping/firebase_options.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Sounds
  await SoundService().initialize();

  // Supabase Credentials
  const supabaseUrl = 'https://opemsvxbapnjiduimmxv.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wZW1zdnhiYXBuamlkdWltbXh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxNDcwMzksImV4cCI6MjA3OTcyMzAzOX0.kWaYg1HcqFGH-YdvmOudO9RTt_t-NntLLRVza3oNoAY';

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  // Initialize Notifications
  await NotificationService().init();

  runApp(
    const ProviderScope(
      child: NixenApp(),
    ),
  );
}

class NixenApp extends ConsumerWidget {
  const NixenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    
    // Check Auth Status
    final session = Supabase.instance.client.auth.currentSession;
    final initialRoute = session != null ? const MainScaffold() : const AuthScreen();

    return MaterialApp(
      title: 'SiiPing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      builder: (context, child) {
        return Stack(
          children: [
            // Global Background Image
            Positioned.fill(
              child: Container(
                color: const Color(0xFF050505), // Base background color
                child: Center(
                  child: Opacity(
                    opacity: 0.1, // Subtle transparency
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Image.asset(
                          'assets/icon/app_icon.png',
                          width: constraints.maxWidth * 0.8, // 80% of screen width
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // The App Content
            if (child != null) child,
          ],
        );
      },
      home: initialRoute,
    );
  }
}
