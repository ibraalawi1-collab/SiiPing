import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siiping/screens/settings/privacy_policy_screen.dart';
import 'package:siiping/l10n/app_localizations.dart';
import 'package:siiping/providers/language_provider.dart';
import 'package:siiping/providers/profile_provider.dart';
import 'package:siiping/screens/admin/admin_dashboard_screen.dart';
import 'package:siiping/screens/subscription/subscription_screen.dart';
import 'package:siiping/screens/profile/widgets/digital_id_card.dart';
import 'package:siiping/screens/profile/widgets/status_selector.dart';
import 'package:siiping/screens/profile/widgets/pin_editor_dialog.dart';
import 'package:siiping/screens/profile/widgets/username_editor_dialog.dart';
import 'package:siiping/widgets/voice_bio_player.dart';
import 'package:siiping/widgets/voice_bio_recorder_dialog.dart';
import 'package:siiping/widgets/profile_visitors_widget.dart';
import 'package:siiping/services/voice_bio_service.dart';
import 'package:siiping/services/media_service.dart';
import 'package:siiping/screens/profile/widgets/profile_updates_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siiping/services/compliance_service.dart';
import 'package:siiping/screens/auth/auth_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          DigitalIdCard(
            username: ref.watch(profileProvider)?.username ?? 'User',
            pin: ref.watch(profileProvider)?.pin ?? 'NX-????',
            avatarUrl: ref.watch(profileProvider)?.avatarUrl,
            statusEmoji: ref.watch(profileProvider)?.statusEmoji ?? '🟢',
            statusText: ref.watch(profileProvider)?.status ?? 'Available',
            subscriptionTier: ref.watch(profileProvider)?.subscriptionTier,
            onStatusTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => const StatusSelector(),
              );
            },
            onAvatarTap: () async {
              final mediaService = MediaService();
              final image = await mediaService.pickImage();
              if (image != null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Updating profile picture...')),
                  );
                }

                final imageUrl = await mediaService.uploadImage(image, 'avatars');
                if (imageUrl != null) {
                  final supabase = Supabase.instance.client;
                  final userId = supabase.auth.currentUser!.id;

                  await supabase.from('profiles').update({
                    'avatar_url': imageUrl,
                  }).eq('id', userId);

                  await supabase.from('updates').insert({
                    'user_id': userId,
                    'content': 'Changed profile picture',
                    'image_url': imageUrl,
                  });

                  ref.read(profileProvider.notifier).fetchProfile();
                }
              }
            },
          ),
          const SizedBox(height: 16),
          ProfileUpdatesWidget(
            profileId: ref.watch(profileProvider)?.id ?? '',
          ),
          const SizedBox(height: 16),
          FutureBuilder<String?>(
            future: VoiceBioService().getVoiceBioUrl(ref.watch(profileProvider)?.id ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Column(
                  children: [
                    VoiceBioPlayer(voiceBioUrl: snapshot.data!),
                    const SizedBox(height: 8),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(color: Colors.grey),
          // Record Voice Bio Button
          ListTile(
            leading: const Icon(Icons.mic, color: Colors.red),
            title: const Text('تسجيل البايو الصوتي'),
            subtitle: const Text('حد أقصى 30 ثانية'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final result = await showDialog(
                context: context,
                builder: (context) => const VoiceBioRecorderDialog(),
              );
              if (result == true) {
                // Refresh to show new voice bio
                ref.read(profileProvider.notifier).fetchProfile();
              }
            },
          ),
          const Divider(color: Colors.grey),
          ProfileVisitorsWidget(
            profileId: ref.watch(profileProvider)?.id ?? '',
          ),
          const SizedBox(height: 32),
          if (ref.watch(profileProvider)?.subscriptionTier != 'elite' && 
              ref.watch(profileProvider)?.role != 'admin')
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(
                AppLocalizations.of(context)!.upgradeButton,
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                );
              },
            ),
          if (ref.watch(profileProvider)?.subscriptionTier != 'elite' && 
              ref.watch(profileProvider)?.role != 'admin')
            const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.pin, color: Colors.blue),
            title: const Text('تغيير PIN'),
            subtitle: const Text('يتطلب اشتراك شهري'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final result = await showDialog(
                context: context,
                builder: (context) => const PinEditorDialog(),
              );
              if (result == true) {
                ref.read(profileProvider.notifier).fetchProfile();
              }
            },
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text('تغيير الاسم'),
            subtitle: const Text('3 مرات مجاناً'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final currentUsername = ref.watch(profileProvider)?.username ?? '';
              final result = await showDialog(
                context: context,
                builder: (context) => UsernameEditorDialog(
                  currentUsername: currentUsername,
                ),
              );
              if (result == true) {
                ref.read(profileProvider.notifier).fetchProfile();
              }
            },
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: const Text('English / العربية'),
            onTap: () {
              ref.read(languageProvider.notifier).toggleLanguage();
            },
          ),
          const Divider(color: Colors.grey),
          if (ref.watch(profileProvider)?.id == 'YOUR_USER_ID_HERE')
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('إعدادات متقدمة'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardScreen(),
                  ),
                );
              },
            ),
          if (ref.watch(profileProvider)?.id == 'YOUR_USER_ID_HERE')
            const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: Text(AppLocalizations.of(context)!.logout ?? 'Logout'),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.blueGrey),
            title: Text(AppLocalizations.of(context)!.termsAndPrivacy),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              AppLocalizations.of(context)!.deleteAccount,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.deleteAccountTitle),
                  content: Text(
                    AppLocalizations.of(context)!.deleteAccountMessage,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await ComplianceService().deleteAccount();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const AuthScreen()),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error deleting account: $e')),
                            );
                          }
                        }
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
