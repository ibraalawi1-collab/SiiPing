import 'package:flutter/material.dart';
import 'package:siiping/services/pin_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PinEditorDialog extends StatefulWidget {
  const PinEditorDialog({super.key});

  @override
  State<PinEditorDialog> createState() => _PinEditorDialogState();
}

class _PinEditorDialogState extends State<PinEditorDialog> {
  final TextEditingController _pinController = TextEditingController();
  final _pinManager = PinManager();
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasActiveCustomPin = false;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _loadPinInfo();
  }

  Future<void> _loadPinInfo() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final hasCustom = await _pinManager.hasActiveCustomPin(userId);
    final expiry = await _pinManager.getCustomPinExpiry(userId);
    setState(() {
      _hasActiveCustomPin = hasCustom;
      _expiryDate = expiry;
    });
  }

  Future<void> _setCustomPin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final newPin = _pinController.text.trim().toUpperCase();

      await _pinManager.setCustomPin(userId, newPin);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تغيير الـ PIN بنجاح! سينتهي بعد شهر'),
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

  Future<void> _revertToOriginal() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await _pinManager.revertToOriginalPin(userId);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الرجوع للـ PIN الأصلي')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تغيير PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasActiveCustomPin && _expiryDate != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✅ لديك PIN مخصص نشط',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ينتهي في: ${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          const Text(
            'PIN جديد (8 أحرف):',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pinController,
            maxLength: 8,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'مثال: ABC12345',
              errorText: _errorMessage,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ملاحظة: يمكنك تغيير الـ PIN باشتراك شهري. بعد انتهاء الشهر سيرجع لـ PIN الأصلي.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        if (_hasActiveCustomPin)
          TextButton(
            onPressed: _isLoading ? null : _revertToOriginal,
            child: const Text('رجوع للأصلي'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _setCustomPin,
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
    _pinController.dispose();
    super.dispose();
  }
}
