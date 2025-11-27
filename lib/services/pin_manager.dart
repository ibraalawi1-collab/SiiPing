import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class PinManager {
  static final PinManager _instance = PinManager._internal();
  factory PinManager() => _instance;
  PinManager._internal();

  final _supabase = Supabase.instance.client;

  /// Generate a random 8-character alphanumeric PIN
  String generateRandomPin() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Validate PIN format (8 characters, alphanumeric)
  bool isValidPinFormat(String pin) {
    if (pin.length != 8) return false;
    final alphanumeric = RegExp(r'^[A-Z0-9]+$');
    return alphanumeric.hasMatch(pin.toUpperCase());
  }

  /// Check if PIN is unique (not used by any other user)
  Future<bool> isPinUnique(String pin, {String? excludeUserId}) async {
    try {
      // Check in both 'pin', 'original_pin', and 'custom_pin' columns
      final query = _supabase
          .from('profiles')
          .select('id')
          .or('pin.eq.$pin,original_pin.eq.$pin,custom_pin.eq.$pin');

      if (excludeUserId != null) {
        query.neq('id', excludeUserId);
      }

      final result = await query;
      return result.isEmpty;
    } catch (e) {
      print('Error checking PIN uniqueness: $e');
      return false;
    }
  }

  /// Set custom PIN with subscription (1 month expiry)
  Future<bool> setCustomPin(String userId, String newPin) async {
    try {
      // Validate format
      if (!isValidPinFormat(newPin)) {
        throw Exception('Invalid PIN format. Must be 8 alphanumeric characters.');
      }

      // Check uniqueness
      final isUnique = await isPinUnique(newPin, excludeUserId: userId);
      if (!isUnique) {
        throw Exception('This PIN is already in use. Please choose another.');
      }

      // Set custom PIN with 1 month expiry
      final expiresAt = DateTime.now().add(const Duration(days: 30));

      await _supabase.from('profiles').update({
        'custom_pin': newPin.toUpperCase(),
        'custom_pin_expires_at': expiresAt.toIso8601String(),
        'pin': newPin.toUpperCase(), // Update current PIN
      }).eq('id', userId);

      return true;
    } catch (e) {
      print('Error setting custom PIN: $e');
      rethrow;
    }
  }

  /// Revert to original PIN (cancel custom PIN)
  Future<bool> revertToOriginalPin(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('original_pin')
          .eq('id', userId)
          .single();

      await _supabase.from('profiles').update({
        'custom_pin': null,
        'custom_pin_expires_at': null,
        'pin': profile['original_pin'],
      }).eq('id', userId);

      return true;
    } catch (e) {
      print('Error reverting to original PIN: $e');
      return false;
    }
  }

  /// Get current active PIN for a user
  Future<String?> getCurrentPin(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('pin, custom_pin, custom_pin_expires_at, original_pin')
          .eq('id', userId)
          .single();

      // Check if custom PIN exists and hasn't expired
      if (profile['custom_pin'] != null && 
          profile['custom_pin_expires_at'] != null) {
        final expiresAt = DateTime.parse(profile['custom_pin_expires_at']);
        if (expiresAt.isAfter(DateTime.now())) {
          return profile['custom_pin'];
        } else {
          // Auto-revert expired custom PIN
          await revertToOriginalPin(userId);
          return profile['original_pin'];
        }
      }

      return profile['original_pin'] ?? profile['pin'];
    } catch (e) {
      print('Error getting current PIN: $e');
      return null;
    }
  }

  /// Check if user has an active custom PIN
  Future<bool> hasActiveCustomPin(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('custom_pin_expires_at')
          .eq('id', userId)
          .single();

      if (profile['custom_pin_expires_at'] == null) return false;

      final expiresAt = DateTime.parse(profile['custom_pin_expires_at']);
      return expiresAt.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// Get custom PIN expiry date
  Future<DateTime?> getCustomPinExpiry(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('custom_pin_expires_at')
          .eq('id', userId)
          .single();

      if (profile['custom_pin_expires_at'] == null) return null;
      return DateTime.parse(profile['custom_pin_expires_at']);
    } catch (e) {
      return null;
    }
  }
}
