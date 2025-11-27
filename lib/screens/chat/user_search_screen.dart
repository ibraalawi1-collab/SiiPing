import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siiping/screens/chat/chat_screen.dart';
import 'package:siiping/widgets/verification_badge.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      
      // Search by username or PIN
      // Note: This requires a text search index or exact match depending on DB setup.
      // For MVP, we'll use ilike on username and exact match on PIN.
      final response = await _supabase
          .from('profiles')
          .select()
          .or('username.ilike.%$query%,pin.eq.$query')
          .neq('id', currentUserId ?? '') // Exclude self
          .limit(20);

      if (mounted) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching users: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by Username or PIN...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search, size: 64, color: Colors.grey.shade700),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty 
                            ? 'Enter a username or PIN to search' 
                            : 'No users found',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade800,
                        child: Text(
                          (user['username'] as String? ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            user['username'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          VerificationBadge(
                            subscriptionTier: user['subscription_tier'],
                            size: 14,
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'PIN: ${user['pin'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.blueAccent),
                        onPressed: () {
                          // Navigate to chat
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
                      ),
                      onTap: () {
                        // Also navigate on tap
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
                ),
    );
  }
}
