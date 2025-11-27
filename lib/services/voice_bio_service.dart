import 'dart:io';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';

class VoiceBioService {
  static final VoiceBioService _instance = VoiceBioService._internal();
  factory VoiceBioService() => _instance;
  VoiceBioService._internal();

  final _recorder = AudioRecorder();
  final _supabase = Supabase.instance.client;
  
  static const int maxDurationSeconds = 30;
  String? _currentRecordingPath;

  /// Start recording voice bio
  Future<bool> startRecording() async {
    try {
      // Check and request permission
      if (await _recorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/voice_bio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );
        
        _currentRecordingPath = filePath;
        return true;
      }
      return false;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      return path ?? _currentRecordingPath;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    try {
      await _recorder.stop();
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _currentRecordingPath = null;
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }

  /// Upload voice bio to Supabase Storage
  Future<String?> uploadVoiceBio(String filePath, String userId) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final fileName = 'voice_bio_$userId.m4a';

      await _supabase.storage
          .from('voice_bios')
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));

      final publicUrl = _supabase.storage
          .from('voice_bios')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading voice bio: $e');
      return null;
    }
  }

  /// Save voice bio URL to user profile
  Future<bool> saveVoiceBioToProfile(String url) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase.from('profiles').update({
        'voice_bio_url': url,
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Error saving voice bio to profile: $e');
      return false;
    }
  }

  /// Delete voice bio
  Future<bool> deleteVoiceBio() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileName = 'voice_bio_$userId.m4a';

      // Delete from storage
      await _supabase.storage.from('voice_bios').remove([fileName]);

      // Remove URL from profile
      await _supabase.from('profiles').update({
        'voice_bio_url': null,
      }).eq('id', userId);

      return true;
    } catch (e) {
      print('Error deleting voice bio: $e');
      return false;
    }
  }

  /// Check if user has voice bio
  Future<String?> getVoiceBioUrl(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('voice_bio_url')
          .eq('id', userId)
          .single();

      return profile['voice_bio_url'];
    } catch (e) {
      print('Error getting voice bio URL: $e');
      return null;
    }
  }

  /// Get recording permission status
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  void dispose() {
    _recorder.dispose();
  }
}
