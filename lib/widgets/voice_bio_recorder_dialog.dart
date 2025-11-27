import 'dart:async';
import 'package:flutter/material.dart';
import 'package:siiping/services/voice_bio_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class VoiceBioRecorderDialog extends StatefulWidget {
  const VoiceBioRecorderDialog({super.key});

  @override
  State<VoiceBioRecorderDialog> createState() => _VoiceBioRecorderDialogState();
}

class _VoiceBioRecorderDialogState extends State<VoiceBioRecorderDialog> {
  final _voiceBioService = VoiceBioService();
  bool _isRecording = false;
  bool _isUploading = false;
  int _recordedSeconds = 0;
  Timer? _timer;
  String? _recordedFilePath;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _voiceBioService.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى السماح بالوصول للميكروفون')),
        );
      }
      return;
    }

    final started = await _voiceBioService.startRecording();
    if (started) {
      setState(() {
        _isRecording = true;
        _recordedSeconds = 0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordedSeconds++);
        
        if (_recordedSeconds >= VoiceBioService.maxDurationSeconds) {
          _stopRecording();
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final filePath = await _voiceBioService.stopRecording();
    setState(() {
      _isRecording = false;
      _recordedFilePath = filePath;
    });
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    await _voiceBioService.cancelRecording();
    setState(() {
      _isRecording = false;
      _recordedSeconds = 0;
      _recordedFilePath = null;
    });
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _recordedFilePath = result.files.single.path;
          _recordedSeconds = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _saveVoiceBio() async {
    if (_recordedFilePath == null) return;

    setState(() => _isUploading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final url = await _voiceBioService.uploadVoiceBio(_recordedFilePath!, userId);

      if (url != null) {
        await _voiceBioService.saveVoiceBioToProfile(url);
        
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ البايو الصوتي بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تسجيل البايو الصوتي 🎙️'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isRecording || _recordedFilePath != null)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                border: Border.all(
                  color: _isRecording ? Colors.red : Colors.green,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  _isRecording 
                      ? '${VoiceBioService.maxDurationSeconds - _recordedSeconds}s'
                      : '✓',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _isRecording ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            _isRecording
                ? 'جاري التسجيل... ($_recordedSeconds ثانية)'
                : _recordedFilePath != null
                    ? 'تم التسجيل! ($_recordedSeconds ثانية)'
                    : 'اضغط للبدء (حد أقصى 30 ثانية)',
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        if (!_isRecording && _recordedFilePath == null)
          ElevatedButton.icon(
            onPressed: _startRecording,
            icon: const Icon(Icons.mic),
            label: const Text('ابدأ التسجيل'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
          // Upload Button
          if (!_isRecording && _recordedFilePath == null)
            IconButton(
              onPressed: _pickAudioFile,
              icon: const Icon(Icons.upload_file),
              tooltip: 'تحميل ملف صوتي',
              color: Theme.of(context).colorScheme.primary,
            ),
        if (_isRecording) ...[ 
          TextButton(
            onPressed: _cancelRecording,
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _stopRecording,
            child: const Text('إيقاف'),
          ),
        ],
        if (_recordedFilePath != null && !_isRecording) ...[
          TextButton(
            onPressed: _cancelRecording,
            child: const Text('إعادة'),
          ),
          ElevatedButton(
            onPressed: _isUploading ? null : _saveVoiceBio,
            child: _isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('حفظ'),
          ),
        ],
      ],
    );
  }
}
