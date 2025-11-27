import 'package:supabase_flutter/supabase_flutter.dart';

class VoiceRoomManager {
  static final VoiceRoomManager _instance = VoiceRoomManager._internal();
  factory VoiceRoomManager() => _instance;
  VoiceRoomManager._internal();

  final _supabase = Supabase.instance.client;
  static const int freeRoomsLimit = 3;

  /// Get voice room creation count
  Future<int> getCreationCount(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('voice_room_count')
          .eq('id', userId)
          .single();

      return profile['voice_room_count'] ?? 0;
    } catch (e) {
      print('Error getting voice room count: $e');
      return 0;
    }
  }

  /// Check if user can create room for free
  Future<bool> canCreateFree(String userId) async {
    final count = await getCreationCount(userId);
    return count < freeRoomsLimit;
  }

  /// Get remaining free creations
  Future<int> getRemainingFreeCreations(String userId) async {
    final count = await getCreationCount(userId);
    return (freeRoomsLimit - count).clamp(0, freeRoomsLimit);
  }

  /// Create voice room (increments count if not paid)
  Future<bool> createVoiceRoom(String userId, String roomName) async {
    try {
      final canCreateFree = await this.canCreateFree(userId);

      if (!canCreateFree) {
        throw Exception('لقد استنفدت المحاولات المجانية (3 مرات). يرجى الاشتراك.');
      }

      // Increment counter
      final currentCount = await getCreationCount(userId);
      await _supabase.from('profiles').update({
        'voice_room_count': currentCount + 1,
      }).eq('id', userId);

      // Note: Actual voice room creation logic would go here
      // For now, we just track the count

      return true;
    } catch (e) {
      print('Error creating voice room: $e');
      rethrow;
    }
  }

  /// Reset voice room count (for premium feature)
  Future<bool> resetCreationCount(String userId) async {
    try {
      await _supabase.from('profiles').update({
        'voice_room_count': 0,
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Error resetting voice room count: $e');
      return false;
    }
  }
}
