import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siiping/l10n/app_localizations.dart';
import 'package:siiping/services/sound_service.dart';

class BroadcastCreateScreen extends StatefulWidget {
  const BroadcastCreateScreen({super.key});

  @override
  State<BroadcastCreateScreen> createState() => _BroadcastCreateScreenState();
}

class _BroadcastCreateScreenState extends State<BroadcastCreateScreen> {
  final _supabase = Supabase.instance.client;
  final Set<String> _selectedUserIds = {};
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  Stream<List<Map<String, dynamic>>> get _usersStream {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('username', ascending: true)
        .map((users) => users.where((u) => u['id'] != _supabase.auth.currentUser!.id).toList());
  }

  Future<void> _sendBroadcast() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _selectedUserIds.isEmpty) return;

    setState(() => _isSending = true);
    SoundService().playSent();

    try {
      final myId = _supabase.auth.currentUser!.id;
      
      // Create a list of futures to send messages in parallel
      final futures = _selectedUserIds.map((userId) {
        return _supabase.from('messages').insert({
          'sender_id': myId,
          'receiver_id': userId,
          'content': content,
          'type': 'text', // Standard text message
        });
      });

      await Future.wait(futures);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Broadcast sent to ${_selectedUserIds.length} users')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Broadcast'),
        actions: [
          if (_selectedUserIds.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${_selectedUserIds.length} selected',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Contact List
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
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userId = user['id'];
                    final isSelected = _selectedUserIds.contains(userId);

                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade800,
                            child: Text(
                              (user['username'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.tealAccent,
                                child: Icon(Icons.check, size: 12, color: Colors.black),
                              ),
                            ),
                        ],
                      ),
                      title: Text(user['username'] ?? 'User'),
                      subtitle: Text(user['status'] ?? 'Available'),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedUserIds.remove(userId);
                          } else {
                            _selectedUserIds.add(userId);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          // Message Input Area (Visible only if users selected)
          if (_selectedUserIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a broadcast message...',
                        border: InputBorder.none,
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_isSending)
                    const CircularProgressIndicator()
                  else
                    FloatingActionButton(
                      onPressed: _sendBroadcast,
                      backgroundColor: Colors.tealAccent,
                      child: const Icon(Icons.send, color: Colors.black),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
