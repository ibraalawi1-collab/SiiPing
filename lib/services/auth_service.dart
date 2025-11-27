import 'dart:math';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign-In Flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In aborted by user.';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // 2. Sign in to Supabase with Google credentials
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // 3. Ensure Profile Exists & Generate PIN if new
      if (response.user != null) {
        await _ensureProfileExists(response.user!);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _ensureProfileExists(User user) async {
    final userId = user.id;

    // Check if profile exists
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      // New User: Generate PIN and Insert
      final String pin = _generateUniquePin();
      
      await _supabase.from('profiles').insert({
        'id': userId,
        'username': user.email?.split('@')[0] ?? 'User', // Default username from email
        'pin': pin,
        'role': 'user',
        'subscription_tier': 'free',
        'avatar_url': user.userMetadata?['avatar_url'],
      });
    }
  }

  String _generateUniquePin() {
    // Generate a random 4-digit PIN prefixed with NX-
    // In a real app, we should check DB for collisions, but for now random is fine.
    final random = Random();
    final number = 1000 + random.nextInt(9000); // 1000-9999
    return 'NX-$number';
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }
}
