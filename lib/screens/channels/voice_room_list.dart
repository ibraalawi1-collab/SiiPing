import 'package:flutter/material.dart';
import 'package:siiping/theme/app_theme.dart';

class VoiceRoomList extends StatelessWidget {
  const VoiceRoomList({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for Voice Rooms
    final rooms = [
      {'title': 'Tech Talk 📱', 'speakers': 3, 'listeners': 12, 'tags': ['Tech', 'Flutter']},
      {'title': 'Chill Vibes 🎵', 'speakers': 1, 'listeners': 45, 'tags': ['Music', 'LoFi']},
      {'title': 'Startup Ideas 💡', 'speakers': 5, 'listeners': 28, 'tags': ['Business']},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final room = rooms[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // TODO: Navigate to VoiceRoomScreen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Joining Room... (UI Demo)')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        room['title'] as String,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildAvatarGroup(),
                      const SizedBox(width: 12),
                      Text(
                        '${room['speakers']} speakers · ${room['listeners']} listening',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: (room['tags'] as List<String>).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarGroup() {
    return SizedBox(
      width: 60,
      height: 30,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade800,
              child: const Icon(Icons.person, size: 16),
            ),
          ),
          Positioned(
            left: 20,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade700,
              child: const Icon(Icons.person, size: 16),
            ),
          ),
          Positioned(
            left: 40,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade600,
              child: const Icon(Icons.person, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
