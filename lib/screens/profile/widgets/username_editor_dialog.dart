import 'package:flutter/material.dart';
import 'package:siiping/services/username_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siiping/screens/subscription/subscription_screen.dart';

class UsernameEditorDialog extends StatefulWidget {
  final String currentUsername;

  const UsernameEditorDialog({
    super.key,
    required this.currentUsername,
  });

  @override
  State<UsernameEditorDialog> createState() => _UsernameEditorDialogState();
}

class _UsernameEditorDialogState extends State<UsernameEditorDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final _usernameManager = UsernameManager();
  bool _isLoading = false;
  String? _errorMessage;
  int _remainingChanges = 0;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.currentUsername;
    _loadRemainingChanges();
  }

  Future<void> _loadRemainingChanges() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final remaining = await _usernameManager.getRemainingFreeChanges(userId);
    setState(() => _remainingChanges = remaining);
  }

  Future<void> _changeUsername() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final canChangeFree = await _usernameManager.canChangeFree(userId);

    // Check if needs payment
    if (!canChangeFree) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('اشتراك مطلوب'),
            content: const Text(
              'لقد استنفدت التغييرات المجانية (3 مرات).\nللمتابعة، يرجى الاشتراك.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionScreen(),
                    ),
                  );
                },
                child: const Text('اشترك الآن'),
              ),
            ],
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newUsername = _usernameController.text.trim();

      if (newUsername.isEmpty) {
        throw Exception('الاسم فارغ');
      }

      await _usernameManager.changeUsername(userId, newUsername);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تغيير الاسم! المتبقي: ${_remainingChanges - 1} تغييرات مجانية'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تغيير الاسم'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _remainingChanges > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _remainingChanges > 0 ? Colors.green : Colors.red,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _remainingChanges > 0 ? Icons.check_circle : Icons.lock,
                  color: _remainingChanges > 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'المتبقي: $_remainingChanges تغييرات مجانية',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Text(
            'الاسم الجديد:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              errorText: _errorMessage,
              border: const OutlineInputBorder(),
            ),
          ),
          if (_remainingChanges == 0)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                '⚠️ لقد استنفدت التغييرات المجانية. الاشتراك مطلوب.',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changeUsername,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('تأكيد'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
