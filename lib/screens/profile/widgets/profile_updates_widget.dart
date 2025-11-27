import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ProfileUpdatesWidget extends StatelessWidget {
  final String profileId;

  const ProfileUpdatesWidget({super.key, required this.profileId});

  Future<List<Map<String, dynamic>>> _fetchRecentUpdates() async {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

    final response = await Supabase.instance.client
        .from('updates')
        .select()
        .eq('user_id', profileId)
        .gte('created_at', twentyFourHoursAgo.toIso8601String())
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  String _formatTime(String timestamp) {
    final date = DateTime.parse(timestamp).toLocal();
    return DateFormat('h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchRecentUpdates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink(); // Hide on error
        }

        final updates = snapshot.data ?? [];

        if (updates.isEmpty) {
          return const SizedBox.shrink(); // Hide if no updates
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Recent Updates (24h)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: updates.length,
              itemBuilder: (context, index) {
                final update = updates[index];
                final content = update['content'] as String?;
                final hasImage = update['image_url'] != null;
                
                // Determine text to show
                String displayText = content ?? '';
                if (displayText.isEmpty && hasImage) {
                  displayText = 'Posted a photo';
                }

                return ListTile(
                  leading: const Icon(Icons.history, color: Colors.white54, size: 20),
                  title: Text(
                    displayText,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatTime(update['created_at']),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  dense: true,
                );
              },
            ),
            const Divider(color: Colors.grey),
          ],
        );
      },
    );
  }
}
