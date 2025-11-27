import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _supabase = Supabase.instance.client;
  
  // Statistics
  int _totalUsers = 0;
  int _premiumUsers = 0;
  int _eliteUsers = 0;
  int _freeUsers = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final users = await _supabase.from('profiles').select('subscription_tier');
      
      setState(() {
        _totalUsers = users.length;
        _premiumUsers = users.where((u) => u['subscription_tier'] == 'premium').length;
        _eliteUsers = users.where((u) => u['subscription_tier'] == 'elite').length;
        _freeUsers = users.where((u) => u['subscription_tier'] == 'free' || u['subscription_tier'] == null).length;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoadingStats = true);
              _loadStatistics();
            },
          ),
        ],
      ),
      body: _isLoadingStats
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  _buildSectionHeader('📊 الإحصائيات', Icons.bar_chart),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('إجمالي المستخدمين', _totalUsers.toString(), Colors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('مشتركين مجاني', _freeUsers.toString(), Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Premium', _premiumUsers.toString(), Colors.purple)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Elite', _eliteUsers.toString(), Colors.amber)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Broadcast Section
                  _buildSectionHeader('📢 إرسال إعلان', Icons.campaign),
                  const SizedBox(height: 16),
                  _BroadcastComposer(),
                  
                  const SizedBox(height: 32),
                  
                  // Recent Users
                  _buildSectionHeader('👥 المستخدمون الجدد', Icons.people),
                  const SizedBox(height: 16),
                  _RecentUsersTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.redAccent, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BroadcastComposer extends StatefulWidget {
  @override
  State<_BroadcastComposer> createState() => _BroadcastComposerState();
}

class _BroadcastComposerState extends State<_BroadcastComposer> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSending = false;
  final _supabase = Supabase.instance.client;

  Future<void> _sendBroadcast() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال العنوان والمحتوى')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await _supabase.from('app_notifications').insert({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'created_by': _supabase.auth.currentUser!.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال الإعلان بنجاح! ✅'),
            backgroundColor: Colors.green,
          ),
        );
        _titleController.clear();
        _contentController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان الإعلان',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'محتوى الإعلان',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendBroadcast,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('إرسال للجميع'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

class _RecentUsersTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .limit(10),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.grey, height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  child: Text(
                    (user['username'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(user['username'] ?? 'Unknown'),
                subtitle: Text('PIN: ${user['pin'] ?? 'N/A'}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTierColor(user['subscription_tier']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getTierColor(user['subscription_tier'])),
                  ),
                  child: Text(
                    user['subscription_tier'] ?? 'free',
                    style: TextStyle(
                      color: _getTierColor(user['subscription_tier']),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getTierColor(String? tier) {
    switch (tier) {
      case 'elite':
        return Colors.amber;
      case 'premium':
        return Colors.purple;
      case 'executive':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
