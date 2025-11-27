import 'package:flutter/material.dart';
import 'package:siiping/screens/feed/feed_screen.dart';
import 'package:siiping/screens/chat/chat_list_screen.dart';
import 'package:siiping/screens/channels/channels_screen.dart';
import 'package:siiping/screens/profile/profile_screen.dart';
import 'package:siiping/theme/app_theme.dart';
import 'package:siiping/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siiping/screens/notifications/notifications_screen.dart';
import 'package:siiping/services/notification_service.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const FeedScreen(),
    const ChatListScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _setupNotificationListener();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _setupNotificationListener() {
    final supabase = Supabase.instance.client;
    final myId = supabase.auth.currentUser?.id;
    if (myId == null) return;

    // Using Realtime for new inserts
    supabase.channel('public:messages').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        final newMsg = payload.newRecord;
        if (newMsg['receiver_id'] == myId) {
          // It's for me!
          final content = newMsg['content'] ?? 'New Message';
          final type = newMsg['type'] ?? 'text';
          
          String notificationBody = content;
          if (type == 'nudge') notificationBody = '⚡ NUDGE!';
          if (type == 'flash') notificationBody = '📸 Flash Message';
          
          NotificationService().showNotification(
            'New Message', // Could look up sender name if we had it
            notificationBody,
          );
        }
      },
    ).subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(), // Adds a nice bounce effect
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.navPulse,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: AppLocalizations.of(context)!.navChat,
          ),
          NavigationDestination(
            icon: const Icon(Icons.broadcast_on_personal_outlined),
            selectedIcon: const Icon(Icons.broadcast_on_personal),
            label: AppLocalizations.of(context)!.navChannels,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.navProfile,
          ),
        ],
      ),
    );
  }
}
