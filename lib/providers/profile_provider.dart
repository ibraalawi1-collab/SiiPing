import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class UserProfile {
  final String id;
  final String username;
  final String pin; // Unique PIN
  final String role; // 'user' or 'admin'
  final String subscriptionTier;

  final String? avatarUrl;
  final String status;
  final String statusEmoji;

  UserProfile({
    required this.id,
    required this.username,
    required this.pin,
    required this.role,
    required this.subscriptionTier,
    this.avatarUrl,
    this.status = 'Available',
    this.statusEmoji = '🟢',
  });
}

class ProfileProvider extends Notifier<UserProfile?> {
  @override
  UserProfile? build() {
    fetchProfile();
    return null; // Initial state is null until fetched
  }

  Future<void> fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        state = UserProfile(
          id: data['id'],
          username: data['username'] ?? 'User',
          pin: data['pin'] ?? await _generateAndSavePin(user.id),
          role: data['role'] ?? 'user',
          subscriptionTier: data['subscription_tier'] ?? 'free',
          avatarUrl: data['avatar_url'],
          status: data['status'] ?? 'Available',
          statusEmoji: data['status_emoji'] ?? '🟢',
        );
      } else {
        // Profile doesn't exist, create one
        final newPin = _generatePin();
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'username': 'User-${user.id.substring(0, 4)}',
          'pin': newPin,
          'role': 'user',
          'subscription_tier': 'free',
          'status': 'Available',
          'status_emoji': '🟢',
        });
        
        state = UserProfile(
          id: user.id,
          username: 'User-${user.id.substring(0, 4)}',
          pin: newPin,
          role: 'user',
          subscriptionTier: 'free',
          avatarUrl: null,
          status: 'Available',
          statusEmoji: '🟢',
        );
      }
    } catch (e) {
      // Handle error silently or log
      print('Error fetching profile: $e');
    }
  }

  Future<void> updateStatus(String statusText, String emoji) async {
    if (state == null) return;

    // Optimistic update
    state = UserProfile(
      id: state!.id,
      username: state!.username,
      pin: state!.pin,
      role: state!.role,
      subscriptionTier: state!.subscriptionTier,
      avatarUrl: state!.avatarUrl,
      status: statusText,
      statusEmoji: emoji,
    );

    try {
      await Supabase.instance.client.from('profiles').update({
        'status': statusText,
        'status_emoji': emoji,
      }).eq('id', state!.id);
    } catch (e) {
      print('Error updating status: $e');
      // Revert if needed, but for now we keep optimistic state
    }
  }

  String _generatePin() {
    final random = Random();
    // Generate 4 digit random number for now, or alphanumeric
    final number = random.nextInt(9000) + 1000;
    return 'NX-$number';
  }

  Future<String> _generateAndSavePin(String userId) async {
    final newPin = _generatePin();
    await Supabase.instance.client
        .from('profiles')
        .update({'pin': newPin})
        .eq('id', userId);
    return newPin;
  }

  void setRole(String role) {
    if (state != null) {
      // This is just for local testing override if needed
      // In production, role should come from DB
    }
  }
}

final profileProvider = NotifierProvider<ProfileProvider, UserProfile?>(ProfileProvider.new);
