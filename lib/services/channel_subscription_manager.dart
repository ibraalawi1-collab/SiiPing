import 'package:supabase_flutter/supabase_flutter.dart';

class ChannelSubscriptionManager {
  static final ChannelSubscriptionManager _instance = ChannelSubscriptionManager._internal();
  factory ChannelSubscriptionManager() => _instance;
  ChannelSubscriptionManager._internal();

  final _supabase = Supabase.instance.client;

  /// Check if user has active channel subscription
  Future<bool> hasActiveSubscription(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('channel_subscription_expires_at')
          .eq('id', userId)
          .single();

      if (profile['channel_subscription_expires_at'] == null) return false;

      final expiresAt = DateTime.parse(profile['channel_subscription_expires_at']);
      return expiresAt.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// Activate channel subscription (1 month)
  Future<bool> activateSubscription(String userId) async {
    try {
      final expiresAt = DateTime.now().add(const Duration(days: 30));

      await _supabase.from('profiles').update({
        'channel_subscription_expires_at': expiresAt.toIso8601String(),
      }).eq('id', userId);

      return true;
    } catch (e) {
      print('Error activating channel subscription: $e');
      return false;
    }
  }

  /// Get subscription expiry date
  Future<DateTime?> getExpiryDate(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('channel_subscription_expires_at')
          .eq('id', userId)
          .single();

      if (profile['channel_subscription_expires_at'] == null) return null;
      return DateTime.parse(profile['channel_subscription_expires_at']);
    } catch (e) {
      return null;
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription(String userId) async {
    try {
      await _supabase.from('profiles').update({
        'channel_subscription_expires_at': null,
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Error canceling subscription: $e');
      return false;
    }
  }
}
