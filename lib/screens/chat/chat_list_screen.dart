import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siiping/l10n/app_localizations.dart';
import 'package:siiping/screens/chat/chat_screen.dart';
import 'package:siiping/screens/chat/broadcast_create_screen.dart';
import 'package:siiping/screens/chat/user_search_screen.dart';

import 'package:siiping/screens/chat/widgets/stories_bar.dart';
import 'package:siiping/screens/chat/widgets/user_header.dart';
import 'package:siiping/widgets/verification_badge.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _supabase = Supabase.instance.client;

  // This is a simplified approach. In a real app, we'd have a 'conversations' table
  // or a complex query to get unique users we've chatted with.
  // For now, we'll just list all users (except self) to start a chat.
  Stream<List<Map<String, dynamic>>> get _usersStream {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('username', ascending: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chatTitle),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.blueAccent),
            tooltip: 'Search Users',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserSearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.campaign, color: Colors.amber),
            tooltip: 'New Broadcast',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BroadcastCreateScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const UserHeader(),
          const StoriesBar(),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!;
                final currentUserId = _supabase.auth.currentUser?.id;
                
                // Filter out self
                final otherUsers = users.where((u) => u['id'] != currentUserId).toList();

                if (otherUsers.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.noUsersFound,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: otherUsers.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final user = otherUsers[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade800,
                        child: Text(
                          (user['username'] as String? ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            user['username'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          VerificationBadge(
                            subscriptionTier: user['subscription_tier'],
                            size: 14,
                          ),
                        ],
                      ),
                      subtitle: Text(
                        user['pin'] ?? '', 
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              partnerId: user['id'],
                              partnerName: user['username'] ?? 'User',
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
