import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siiping/l10n/app_localizations.dart';

import 'package:siiping/services/sound_service.dart';

class ChannelDetailScreen extends StatefulWidget {
  final String channelId;
  final String channelName;
  final String ownerId;

  const ChannelDetailScreen({
    super.key,
    required this.channelId,
    required this.channelName,
    required this.ownerId,
  });

  @override
  State<ChannelDetailScreen> createState() => _ChannelDetailScreenState();
}

class _ChannelDetailScreenState extends State<ChannelDetailScreen> {
  final _supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> get _postsStream {
    return _supabase
        .from('channel_posts')
        .stream(primaryKey: ['id'])
        .eq('channel_id', widget.channelId)
        .order('created_at', ascending: false);
  }

  Future<void> _createPost() async {
    final TextEditingController controller = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.createUpdateTitle), // Reuse key
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.updateContentHint, // Reuse key
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          ElevatedButton(
            onPressed: () async {
              final content = controller.text.trim();
              if (content.isNotEmpty) {
                // Play sound
                SoundService().playSent();
                
                try {
                  await _supabase.from('channel_posts').insert({
                    'channel_id': widget.channelId,
                    'content': content,
                  });
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.postButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _supabase.auth.currentUser?.id == widget.ownerId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _postsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!;
          if (posts.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noUpdates, // Reuse key
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['content'] ?? '',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(post['created_at']),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              onPressed: _createPost,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString).toLocal();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
