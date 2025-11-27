import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:siiping/l10n/app_localizations.dart';
import 'package:siiping/services/media_service.dart';
import 'package:siiping/widgets/full_screen_image_viewer.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _supabase = Supabase.instance.client;
  final _mediaService = MediaService();
  late Stream<List<Map<String, dynamic>>> _updatesStream;
  
  final TextEditingController _textController = TextEditingController();
  XFile? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _updatesStream = _getUpdatesStream();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _getUpdatesStream() {
    return _supabase
        .from('updates')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _updatesStream = _getUpdatesStream();
    });
    // Add a small delay to make the refresh feel substantial
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _postUpdate() async {
    final content = _textController.text.trim();
    if (content.isEmpty && _selectedImage == null) return;

    setState(() => _isUploading = true);
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _mediaService.uploadImage(_selectedImage!, 'siiping_media');
      }

      await _supabase.from('updates').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'content': content,
        'image_url': imageUrl,
      });
      
      _textController.clear();
      setState(() {
        _selectedImage = null;
      });
      
      _refreshFeed(); // Auto-refresh after post
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.feedTitle),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Fixed Input Area (BBM Style)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.person, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.updateContentHint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 52), // Align with text
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedImage!.path),
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 52), // Indent to match text
                    IconButton(
                      onPressed: () async {
                        final image = await _mediaService.pickImage();
                        if (image != null) {
                          setState(() => _selectedImage = image);
                        }
                      },
                      icon: Icon(Icons.image_outlined, color: Theme.of(context).colorScheme.secondary),
                      tooltip: 'Add Image',
                    ),
                    IconButton(
                      onPressed: () {
                        // Camera implementation would go here
                      },
                      icon: Icon(Icons.camera_alt_outlined, color: Theme.of(context).colorScheme.secondary),
                      tooltip: 'Take Photo',
                    ),
                    const Spacer(),
                    if (_isUploading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      ElevatedButton(
                        onPressed: _postUpdate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          minimumSize: Size.zero,
                        ),
                        child: Text(AppLocalizations.of(context)!.postButton),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Feed List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshFeed,
              color: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _updatesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final updates = snapshot.data!;
                  if (updates.isEmpty) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.noUpdates,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: updates.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final update = updates[index];
                      final hasImage = update['image_url'] != null;
                      
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: const Icon(Icons.person, color: Colors.black),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'User', // Placeholder for username
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(update['created_at']),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.more_horiz),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            if (update['content'] != null && update['content'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Text(
                                  update['content'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            if (hasImage) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImageViewer(
                                        imageUrl: update['image_url'],
                                        heroTag: 'image_${update['id']}',
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: 'image_${update['id']}',
                                  child: CachedNetworkImage(
                                    imageUrl: update['image_url'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 250,
                                    placeholder: (context, url) => Container(
                                      height: 250,
                                      color: Colors.grey.shade900,
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      height: 250,
                                      color: Colors.grey.shade900,
                                      child: const Icon(Icons.error, color: Colors.red),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.favorite_border),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.comment_outlined),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context).viewInsets.bottom,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            height: 500,
                                            child: Column(
                                              children: [
                                                const Text(
                                                  'Comments',
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 16),
                                                Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'No comments yet.',
                                                      style: TextStyle(color: Colors.grey.shade600),
                                                    ),
                                                  ),
                                                ),
                                                TextField(
                                                  decoration: InputDecoration(
                                                    hintText: 'Add a comment...',
                                                    suffixIcon: IconButton(
                                                      icon: const Icon(Icons.send),
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString).toLocal();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
