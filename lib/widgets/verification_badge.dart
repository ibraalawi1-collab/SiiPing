import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final String? subscriptionTier;
  final double size;

  const VerificationBadge({
    super.key,
    required this.subscriptionTier,
    this.size = 16,
  });

  bool get _isVerified {
    return subscriptionTier != null && 
           (subscriptionTier == 'premium' || 
            subscriptionTier == 'elite' || 
            subscriptionTier == 'executive');
  }

  Color get _badgeColor {
    switch (subscriptionTier) {
      case 'elite':
        return Colors.amber; // Gold for Elite
      case 'executive':
        return Colors.purple; // Purple for Executive
      case 'premium':
        return Colors.blue; // Blue for Premium
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVerified) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(
        Icons.verified,
        size: size,
        color: _badgeColor,
      ),
    );
  }
}
