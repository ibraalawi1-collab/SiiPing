import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siiping/providers/profile_provider.dart';

class StatusSelector extends ConsumerWidget {
  const StatusSelector({super.key});

  final List<Map<String, String>> _statuses = const [
    {'emoji': '🟢', 'text': 'Available'},
    {'emoji': '💻', 'text': 'Coding'},
    {'emoji': '🚗', 'text': 'Driving'},
    {'emoji': '🎮', 'text': 'Gaming'},
    {'emoji': '🎵', 'text': 'Vibing'},
    {'emoji': '😴', 'text': 'Sleeping'},
    {'emoji': '⛔', 'text': 'Busy'},
    {'emoji': '👻', 'text': 'Invisible'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStatus = ref.watch(profileProvider)?.status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Set Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _statuses.length,
            itemBuilder: (context, index) {
              final status = _statuses[index];
              final isSelected = currentStatus == status['text'];

              return GestureDetector(
                onTap: () {
                  ref.read(profileProvider.notifier).updateStatus(
                    status['text']!,
                    status['emoji']!,
                  );
                  Navigator.pop(context);
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.2) 
                            : Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: isSelected 
                            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Text(
                        status['emoji']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status['text']!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
