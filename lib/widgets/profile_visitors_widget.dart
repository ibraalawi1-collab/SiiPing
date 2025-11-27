import 'package:flutter/material.dart';
import 'package:siiping/services/profile_visitor_service.dart';
import 'package:siiping/widgets/verification_badge.dart';

class ProfileVisitorsWidget extends StatefulWidget {
  final String profileId;

  const ProfileVisitorsWidget({
    super.key,
    required this.profileId,
  });

  @override
  State<ProfileVisitorsWidget> createState() => _ProfileVisitorsWidgetState();
}

class _ProfileVisitorsWidgetState extends State<ProfileVisitorsWidget> {
  final _visitorService = ProfileVisitorService();
  List<Map<String, dynamic>> _visitors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  Future<void> _loadVisitors() async {
    final visitors = await _visitorService.getRecentVisitors(widget.profileId, limit: 10);
    if (mounted) {
      setState(() {
        _visitors = visitors;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility, color: Colors.tealAccent),
              const SizedBox(width: 8),
              Text(
                'زوار الملف الشخصي',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_visitors.length}',
                style: const TextStyle(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_visitors.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'لا يوجد زوار بعد',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _visitors.length,
              separatorBuilder: (context, index) => const Divider(height: 8),
              itemBuilder: (context, index) {
                final visit = _visitors[index];
                final profile = visit['profiles'];
                final username = profile?['username'] ?? 'User';
                final subscriptionTier = profile?['subscription_tier'];
                final visitedAt = DateTime.parse(visit['visited_at']);
                final timeAgo = _formatTimeAgo(visitedAt);

                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade800,
                    child: Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        username,
                        style: const TextStyle(fontSize: 14),
                      ),
                      VerificationBadge(
                        subscriptionTier: subscriptionTier,
                        size: 12,
                      ),
                    ],
                  ),
                  trailing: Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
