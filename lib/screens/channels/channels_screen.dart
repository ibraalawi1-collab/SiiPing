import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siiping/l10n/app_localizations.dart';
import 'package:siiping/screens/channels/channel_detail_screen.dart';
import 'package:siiping/screens/channels/voice_room_list.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> get _channelsStream {
    return _supabase
        .from('channels')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> _createChannel(BuildContext context) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    // Check subscription tier
    final profile = await _supabase
        .from('profiles')
        .select('subscription_tier, role')
        .eq('id', myId)
        .single();

    final tier = profile['subscription_tier'] ?? 'free';
    final role = profile['role'] ?? 'user';

    if (tier == 'free' && role != 'admin') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium feature - Upgrade to Elite to create channels')),
        );
      }
      return;
    }

    // Show Create Dialog
    final nameController = TextEditingController();
    final descController = TextEditingController();

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Create Channel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Channel Name',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;

                try {
                  await _supabase.from('channels').insert({
                    'name': nameController.text,
                    'description': descController.text,
                    'creator_id': myId,
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Channel created!')),
                      );
                    }
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Channels'),
            Tab(text: 'Voice Rooms'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChannelsList(context),
          const VoiceRoomList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createChannel(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChannelsList(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _channelsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final channels = snapshot.data ?? [];

        if (channels.isEmpty) {
          return const Center(child: Text('No channels yet'));
        }

        return ListView.builder(
          itemCount: channels.length,
          itemBuilder: (context, index) {
            final channel = channels[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.tag)),
              title: Text(channel['name'] ?? 'Unnamed'),
              subtitle: Text(channel['description'] ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChannelDetailScreen(
                      channelId: channel['id'],
                      channelName: channel['name'] ?? 'Channel',
                      ownerId: channel['creator_id'] ?? '',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
