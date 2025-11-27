import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:siiping/services/media_service.dart';
import 'package:siiping/services/sound_service.dart';
import 'package:siiping/screens/chat/story_editor_screen.dart';
import 'package:siiping/widgets/full_screen_image_viewer.dart';

class StoriesBar extends StatefulWidget {
  const StoriesBar({super.key});

  @override
  State<StoriesBar> createState() => _StoriesBarState();
}

class _StoriesBarState extends State<StoriesBar> {
  final _supabase = Supabase.instance.client;
  final _mediaService = MediaService();
  
  Stream<List<Map<String, dynamic>>> get _storiesStream {
    return _supabase
        .from('stories')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  Future<void> _uploadStory() async {
    final image = await _mediaService.pickImage();
    if (image == null) return;

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryEditorScreen(imageFile: image),
        ),
      );
    }
  }

  void _viewStory(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageUrl: imageUrl,
          heroTag: imageUrl, // Use URL as tag for stories
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _storiesStream,
        builder: (context, snapshot) {
          final stories = snapshot.data ?? [];
          final myId = _supabase.auth.currentUser?.id;

          // Deduplicate stories by user (show latest)
          // For MVP, we just show all active stories or maybe group them?
          // Let's just show individual story bubbles for now for simplicity.
          
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stories.length + 1, // +1 for "Add Story"
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                // Add Story Button
                return GestureDetector(
                  onTap: _uploadStory,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade700, width: 2),
                          color: Colors.grey.shade900,
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your Story',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                );
              }

              final story = stories[index - 1];
              final isMe = story['user_id'] == myId;
              
              return GestureDetector(
                onTap: () => _viewStory(context, story['media_url']),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3), // Space for border
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.cyanAccent, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: ClipOval(
                          child: const Icon(Icons.person, color: Colors.white), // Placeholder avatar
                          // In real app: CachedNetworkImage(imageUrl: avatarUrl)
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMe ? 'You' : 'User', // Placeholder name
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
