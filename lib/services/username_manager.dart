import 'package:supabase_flutter/supabase_flutter.dart';

class UsernameManager {
  static final UsernameManager _instance = UsernameManager._internal();
  factory UsernameManager() => _instance;
  UsernameManager._internal();

  final _supabase = Supabase.instance.client;
  static const int freeChangesLimit = 3;

  /// Get username change count for a user
  Future<int> getChangeCount(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('username_changes_count')
          .eq('id', userId)
          .single();

      return profile['username_changes_count'] ?? 0;
    } catch (e) {
      print('Error getting username change count: $e');
      return 0;
    }
  }

  /// Check if user can change username for free
  Future<bool> canChangeFree(String userId) async {
    final count = await getChangeCount(userId);
    return count < freeChangesLimit;
  }

  /// Get remaining free changes
  Future<int> getRemainingFreeChanges(String userId) async {
    final count = await getChangeCount(userId);
    return (freeChangesLimit - count).clamp(0, freeChangesLimit);
  }

  /// Check if username is unique
  Future<bool> isUsernameUnique(String username, {String? excludeUserId}) async {
    try {
      final query = _supabase
          .from('profiles')
          .select('id')
          .eq('username', username);

      if (excludeUserId != null) {
        query.neq('id', excludeUserId);
      }

      final result = await query;
      return result.isEmpty;
    } catch (e) {
      print('Error checking username uniqueness: $e');
      return false;
    }
  }

  /// Change username (increments change count)
  Future<bool> changeUsername(String userId, String newUsername) async {
    try {
      // Check uniqueness
      final isUnique = await isUsernameUnique(newUsername, excludeUserId: userId);
      if (!isUnique) {
        throw Exception('هذا الاسم مستخدم بالفعل');
      }

      // Get current count
      final currentCount = await getChangeCount(userId);

      // Update username and increment counter
      await _supabase.from('profiles').update({
        'username': newUsername,
        'username_changes_count': currentCount + 1,
      }).eq('id', userId);

      return true;
    } catch (e) {
      print('Error changing username: $e');
      rethrow;
    }
  }

  /// Reset username change count (for premium feature or admin)
  Future<bool> resetChangeCount(String userId) async {
    try {
      await _supabase.from('profiles').update({
        'username_changes_count': 0,
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Error resetting change count: $e');
      return false;
    }
  }
}
