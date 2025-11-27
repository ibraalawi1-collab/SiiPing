import 'package:supabase_flutter/supabase_flutter.dart';

class ComplianceService {
  final _supabase = Supabase.instance.client;

  Future<void> blockUser(String userId) async {
    final myId = _supabase.auth.currentUser!.id;
    await _supabase.from('blocks').insert({
      'blocker_id': myId,
      'blocked_id': userId,
    });
  }

  Future<void> unblockUser(String userId) async {
    final myId = _supabase.auth.currentUser!.id;
    await _supabase.from('blocks').delete().match({
      'blocker_id': myId,
      'blocked_id': userId,
    });
  }

  Future<void> reportUser(String userId, String reason, String description) async {
    final myId = _supabase.auth.currentUser!.id;
    await _supabase.from('reports').insert({
      'reporter_id': myId,
      'reported_id': userId,
      'reason': reason,
      'description': description,
    });
  }

  Future<void> deleteAccount() async {
    final myId = _supabase.auth.currentUser!.id;
    
    // In a real app, you might use an Edge Function to delete everything securely.
    // For now, we will mark the profile as deleted or try to delete directly if RLS allows.
    // Assuming RLS allows users to delete their own profile:
    
    // 1. Delete profile (cascade should handle related data if set up, otherwise manual cleanup)
    try {
      await _supabase.from('profiles').delete().eq('id', myId);
      
      // 2. Sign out
      await _supabase.auth.signOut();
    } catch (e) {
      // If direct delete fails (e.g. due to foreign key constraints without cascade),
      // we might just sign out or call a specific function.
      // For this implementation, we'll assume success or handle error in UI.
      rethrow;
    }
  }
}
