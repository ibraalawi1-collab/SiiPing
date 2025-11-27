import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siiping/l10n/app_localizations.dart';
import 'package:siiping/providers/profile_provider.dart';
import 'package:siiping/theme/app_theme.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isLoading = false;

  Future<void> _upgradeToElite() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      
      // Mock Payment Processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Update subscription tier
      await Supabase.instance.client
          .from('profiles')
          .update({'subscription_tier': 'elite'})
          .eq('id', userId);

      // Refresh profile provider
      // ignore: unused_result
      ref.refresh(profileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.upgradeSuccess)),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider);
    final isElite = profile?.subscriptionTier == 'elite' || profile?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: [
              // Free Tier Card
              _buildTierCard(
                context,
                title: l10n.freeTier,
                price: l10n.freePrice,
                features: [
                  l10n.featureReadFeed,
                  l10n.featureJoinChannels,
                  l10n.featureBasicChat,
                ],
                isActive: !isElite,
                onTap: () {},
              ),
              const SizedBox(height: 24),
              // Elite Tier Card
              _buildTierCard(
                context,
                title: l10n.eliteTier,
                price: l10n.elitePrice,
                features: [
                  l10n.featureCreateChannels,
                  l10n.featureGhostMode,
                  l10n.featurePrioritySupport,
                  l10n.featureVerifiedBadge,
                ],
                isActive: isElite,
                isPremium: true,
                onTap: isElite ? null : _upgradeToElite,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required bool isActive,
    bool isPremium = false,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final borderColor = isActive 
        ? (isPremium ? AppTheme.platinum : Colors.grey) 
        : Colors.transparent;
    
    return Card(
      color: isPremium ? const Color(0xFF1A1A1A) : const Color(0xFF121212),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isPremium ? AppTheme.platinum : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isActive)
                  const Icon(Icons.check_circle, color: AppTheme.platinum),
              ],
            ),
            Text(
              price,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            const Divider(height: 32),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check, size: 16, color: isPremium ? AppTheme.platinum : Colors.grey),
                  const SizedBox(width: 8),
                  Text(f, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            )),
            const SizedBox(height: 24),
            if (!isActive && isPremium)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.platinum,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(AppLocalizations.of(context)!.upgradeButton),
                ),
              ),
            if (isActive)
              Center(
                child: Text(
                  AppLocalizations.of(context)!.currentPlan,
                  style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
