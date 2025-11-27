import 'dart:ui';
import 'package:flutter/material.dart';

class FlashMessageBubble extends StatefulWidget {
  final String content;
  final bool isMe;

  const FlashMessageBubble({
    super.key,
    required this.content,
    required this.isMe,
  });

  @override
  State<FlashMessageBubble> createState() => _FlashMessageBubbleState();
}

class _FlashMessageBubbleState extends State<FlashMessageBubble> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => setState(() => _isRevealed = true),
      onLongPressEnd: (_) => setState(() => _isRevealed = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isMe ? Colors.tealAccent.shade700 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.amber.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flash_on, 
              size: 16, 
              color: _isRevealed ? Colors.amber : Colors.white54
            ),
            const SizedBox(width: 8),
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _isRevealed ? 0 : 8,
                sigmaY: _isRevealed ? 0 : 8,
              ),
              child: Text(
                widget.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
