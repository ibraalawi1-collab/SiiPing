import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Preload sounds if needed (optional for small files)
  Future<void> initialize() async {
    // AudioPlayers usually handles loading on play, but we can pre-cache if needed.
    if (kDebugMode) {
      print('SoundService initialized');
    }
  }

  Future<void> playSent() async {
    try {
      await _player.play(AssetSource('sounds/message_sent.mp3'));
    } catch (e) {
      debugPrint('Error playing sent sound: $e');
    }
  }

  Future<void> playReceived() async {
    try {
      await _player.play(AssetSource('sounds/message_received.mp3'));
    } catch (e) {
      debugPrint('Error playing received sound: $e');
    }
  }

  Future<void> playPing() async {
    try {
      await _player.play(AssetSource('sounds/ping_alert.mp3'));
    } catch (e) {
      debugPrint('Error playing ping sound: $e');
    }
  }
}
