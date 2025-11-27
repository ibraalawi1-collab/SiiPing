import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileVisitorService {
  static final ProfileVisitorService _instance = ProfileVisitorService._internal();
  factory ProfileVisitorService() => _instance;
  ProfileVisitorService._internal();

  final _supabase = Supabase.instance.client;

  /// Log a profile visit
  Future<bool> logVisit(String profileId) async {
    try {
      final myId = _supabase.auth.currentUser?.id;
      if (myId == null || myId == profileId) return false; // Don't log self-visits

      // Check if profile owner wants to track visitors
      final profile = await _supabase
          .from('profiles')
          .select('track_visitors')
          .eq('id', profileId)
          .single();

      if (profile['track_visitors'] != true) return false;

      // Log the visit
      await _supabase.from('profile_visits').insert({
        'profile_id': profileId,
        'visitor_id': myId,
      });

      return true;
    } catch (e) {
      // Duplicate visit in same timestamp is ok (unique constraint)
      print('Visit log: $e');
      return false;
    }
  }

  /// Get recent visitors for a profile
  Future<List<Map<String, dynamic>>> getRecentVisitors(String profileId, {int limit = 10}) async {
    try {
      final visits = await _supabase
          .from('profile_visits')
          .select('visitor_id, visited_at, profiles!profile_visits_visitor_id_fkey(username, subscription_tier)')
          .eq('profile_id', profileId)
          .order('visited_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(visits);
    } catch (e) {
      print('Error getting visitors: $e');
      return [];
    }
  }

  Future<int> getVisitorCount(String profileId) async {
    try {
      final count = await _supabase
          .from('profile_visits')
          .count()
          .eq('profile_id', profileId);

      return count;
    } catch (e) {
      print('Error getting visitor count: $e');
      return 0;
    }
  }

  /// Toggle visitor tracking
  Future<bool> toggleVisitorTracking(bool enabled) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase.from('profiles').update({
        'track_visitors': enabled,
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Error toggling visitor tracking: $e');
      return false;
    }
  }

  /// Check if visitor tracking is enabled
  Future<bool> isTrackingEnabled(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('track_visitors')
          .eq('id', userId)
          .single();

      return profile['track_visitors'] == true;
    } catch (e) {
      return true; // Default to enabled
    }
  }
}
