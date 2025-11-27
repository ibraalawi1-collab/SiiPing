import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siiping/l10n/app_localizations.dart';

import 'package:siiping/services/sound_service.dart';

import 'package:siiping/screens/chat/stories_bar.dart';
import 'package:siiping/screens/chat/widgets/flash_message_bubble.dart';
import 'package:siiping/screens/chat/widgets/temporary_message_bubble.dart';
import 'package:siiping/utils/shake_widget.dart';
import 'package:siiping/services/encryption_service.dart';
import 'package:siiping/services/compliance_service.dart';

class ChatScreen extends StatefulWidget {
  final String partnerId;
  final String partnerName;

  const ChatScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();
  int _previousMessageCount = 0;

  Stream<List<Map<String, dynamic>>> get _messagesStream {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((messages) {
          // Filter messages for this conversation
          final myId = _supabase.auth.currentUser!.id;
          final filtered = messages.where((m) {
            return (m['sender_id'] == myId && m['receiver_id'] == widget.partnerId) ||
                   (m['sender_id'] == widget.partnerId && m['receiver_id'] == myId);
          }).toList();
          
          // Check for new incoming messages
          if (filtered.length > _previousMessageCount) {
             final lastMsg = filtered.last;
             if (lastMsg['sender_id'] != myId && _previousMessageCount > 0) {
               if (lastMsg['type'] == 'nudge') {
                 SoundService().playPing();
                 _shakeKey.currentState?.shake();
               } else {
                 SoundService().playReceived();
               }
             }
             _previousMessageCount = filtered.length;
          }
          
          return filtered;
        });
  }

  Future<void> _sendMessage({
    String type = 'text', 
    String? content, 
    Duration? expiresIn,
    bool encrypted = false,
  }) async {
    final msgContent = content ?? _controller.text.trim();
    if (msgContent.isEmpty && type == 'text') return;

    if (type == 'text') {
      _controller.clear();
      SoundService().playSent();
    } else if (type == 'nudge') {
      SoundService().playPing(); // Play for self too
    }
    
    try {
      // Encrypt if requested
      String finalContent = type == 'nudge' ? '⚡ NUDGE!' : msgContent;
      if (encrypted && type == 'text') {
        final encryptionService = EncryptionService();
        finalContent = encryptionService.encryptMessage(finalContent, widget.partnerId);
      }

      // Calculate expiry time
      DateTime? expiresAt;
      if (expiresIn != null) {
        expiresAt = DateTime.now().add(expiresIn);
      }

      await _supabase.from('messages').insert({
        'sender_id': _supabase.auth.currentUser!.id,
        'receiver_id': widget.partnerId,
        'content': finalContent,
        'type': type,
        'expires_at': expiresAt?.toIso8601String(),
        'is_encrypted': encrypted,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Message Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('5 seconds'),
              onTap: () {
                Navigator.pop(context);
                _sendMessage(type: 'text', expiresIn: const Duration(seconds: 5));
              },
            ),
            ListTile(
              title: const Text('1 minute'),
              onTap: () {
                Navigator.pop(context);
                _sendMessage(type: 'text', expiresIn: const Duration(minutes: 1));
              },
            ),
            ListTile(
              title: const Text('1 hour'),
              onTap: () {
                Navigator.pop(context);
                _sendMessage(type: 'text', expiresIn: const Duration(hours: 1));
              },
            ),
            ListTile(
              title: const Text('24 hours'),
              onTap: () {
                Navigator.pop(context);
                _sendMessage(type: 'text', expiresIn: const Duration(hours: 24));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShakeWidget(
      key: _shakeKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.partnerName),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'report') {
                  // Show Report Dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Report User'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Spam'),
                            onTap: () {
                              ComplianceService().reportUser(widget.partnerId, 'spam', 'User reported as spam');
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User reported')));
                            },
                          ),
                          ListTile(
                            title: const Text('Abusive Content'),
                            onTap: () {
                              ComplianceService().reportUser(widget.partnerId, 'abusive', 'User reported for abusive content');
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User reported')));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (value == 'block') {
                  // Block User
                  await ComplianceService().blockUser(widget.partnerId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked')));
                    Navigator.pop(context); // Exit chat
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Text('Report User'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'block',
                    child: Text('Block User', style: TextStyle(color: Colors.red)),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Stories (Glimpses)
            const StoriesBar(),
            const Divider(height: 1, color: Colors.grey),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.noMessages,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message['sender_id'] == _supabase.auth.currentUser!.id;
                      final isNudge = message['type'] == 'nudge';
                      final isFlash = message['type'] == 'flash';
                      final isTemporary = message['expires_at'] != null;
                      final isEncrypted = message['is_encrypted'] == true;

                      // Handle flash messages
                      if (isFlash) {
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: FlashMessageBubble(
                            content: message['content'] ?? '',
                            isMe: isMe,
                          ),
                        );
                      }

                      // Handle temporary messages
                      if (isTemporary) {
                        final expiresAt = DateTime.parse(message['expires_at']);
                        if (expiresAt.isBefore(DateTime.now())) {
                          return const SizedBox.shrink(); // Hide expired
                        }

                        String displayContent = message['content'] ?? '';
                        if (isEncrypted && !isMe) {
                          final encryptionService = EncryptionService();
                          displayContent = encryptionService.decryptMessage(
                            displayContent, 
                            message['sender_id']
                          );
                        }

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: TemporaryMessageBubble(
                            content: displayContent,
                            isMe: isMe,
                            expiresAt: expiresAt,
                            onExpired: () {
                              // Optional: Could delete from DB here
                            },
                          ),
                        );
                      }

                      // Decrypt if encrypted
                      String displayContent = message['content'] ?? '';
                      if (isEncrypted && !isMe) {
                        final encryptionService = EncryptionService();
                        displayContent = encryptionService.decryptMessage(
                          displayContent, 
                          message['sender_id']
                        );
                      }

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isNudge 
                                ? Colors.redAccent.withOpacity(0.2) 
                                : (isMe ? Colors.tealAccent.shade700 : Colors.grey.shade800),
                            borderRadius: BorderRadius.circular(12),
                            border: isNudge ? Border.all(color: Colors.redAccent) : null,
                          ),
                          child: Text(
                            displayContent,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isNudge ? FontWeight.bold : FontWeight.normal,
                              fontStyle: isNudge ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.messageHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.flash_on, color: Colors.amber),
                    tooltip: 'Send Nudge',
                    onPressed: () => _sendMessage(type: 'nudge'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility_off, color: Colors.purpleAccent),
                    tooltip: 'Send Flash Message',
                    onPressed: () => _sendMessage(type: 'flash'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.tealAccent),
                    onPressed: () => _sendMessage(type: 'text'),
                    onLongPress: () {
                      // Show options dialog
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Send Options',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                leading: const Icon(Icons.timer, color: Colors.orange),
                                title: const Text('Send with Timer'),
                                subtitle: const Text('Message will auto-delete'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showTimerDialog();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.lock, color: Colors.green),
                                title: const Text('Send Encrypted'),
                                subtitle: const Text('End-to-end encrypted'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _sendMessage(type: 'text', encrypted: true);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
