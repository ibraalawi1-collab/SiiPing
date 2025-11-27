import 'dart:async';
import 'package:flutter/material.dart';

class TemporaryMessageBubble extends StatefulWidget {
  final String content;
  final bool isMe;
  final DateTime expiresAt;
  final VoidCallback? onExpired;

  const TemporaryMessageBubble({
    super.key,
    required this.content,
    required this.isMe,
    required this.expiresAt,
    this.onExpired,
  });

  @override
  State<TemporaryMessageBubble> createState() => _TemporaryMessageBubbleState();
}

class _TemporaryMessageBubbleState extends State<TemporaryMessageBubble> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.expiresAt.difference(DateTime.now());
    
    // Start countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = widget.expiresAt.difference(DateTime.now());
        if (_remaining.isNegative || _remaining.inSeconds == 0) {
          _timer.cancel();
          widget.onExpired?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative || _remaining.inSeconds == 0) {
      return const SizedBox.shrink(); // Hide expired message
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.tealAccent.shade700 : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.orange.shade300),
              const SizedBox(width: 4),
              Text(
                _formatDuration(_remaining),
                style: TextStyle(
                  color: Colors.orange.shade300,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.content,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
