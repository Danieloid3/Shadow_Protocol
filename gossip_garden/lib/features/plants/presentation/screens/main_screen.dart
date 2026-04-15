import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/navigation_provider.dart';

import 'dashboard_screen.dart';
import 'chat_list_screen.dart';
import 'garden_view_screen.dart';
import 'profile_screen.dart';
import 'plant_profile_screen.dart';
import 'plant_chat_screen.dart';

import '../widgets/animated_bottom_nav.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      print('MainScreen building');
      final nav = ref.watch(navigationProvider);
      final notifier = ref.read(navigationProvider.notifier);
      print(
          'Navigation state: activeTab=${nav.activeTab}, showOnboarding=${nav.showOnboarding}');

      /// ONBOARDING SIMPLE
      if (nav.showOnboarding) {
        print('Showing onboarding screen');
        return Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Container(
              padding: EdgeInsets.all(40),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('GOSSIP GARDEN',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print('Onboarding button pressed');
                      notifier.completeOnboarding();
                    },
                    child: const Text('ENTRAR AL JARDÍN'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      print('Showing main app screen');
      final hasOverlay =
          nav.showChat || nav.showPlantProfile || nav.selectedFriendId != null;

      return Scaffold(
        body: Stack(
          children: [
            /// MAIN CONTENT WITH TAB TRANSITIONS
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: hasOverlay ? 0 : 90),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                        CurvedAnimation(
                            parent: animation, curve: Curves.easeOut),
                      ),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: IndexedStack(
                    key: ValueKey<TabId>(nav.activeTab),
                    index: nav.activeTab.index,
                    children: [
                      DashboardScreen(
                        onSelectPlant: notifier.selectPlant,
                        onOpenChat: notifier.openChat,
                        onOpenFriendGarden: notifier.openFriendGarden,
                      ),
                      const ChatListScreen(),
                      const GardenViewScreen(),
                      const ProfileScreen(),
                    ],
                  ),
                ),
              ),
            ),

            /// OVERLAY SCREENS (CHAT, PLANT PROFILE)
            if (hasOverlay) _buildOverlay(nav, notifier),

            /// FLOATING BOTTOM NAVIGATION
            if (!hasOverlay)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedBottomNav(
                  activeTab: nav.activeTab,
                  onTabChange: notifier.changeTab,
                ),
              ),
          ],
        ),
      );
    } catch (e, stack) {
      print('ERROR in MainScreen.build: $e');
      print('Stack trace: $stack');
      return Scaffold(
        body: Center(
          child: Text('Error: $e'),
        ),
      );
    }
  }

  Widget _buildOverlay(NavigationState nav, NavigationNotifier notifier) {
    if (nav.showPlantProfile) {
      return PlantProfileScreen(
        plantId: nav.selectedPlantId,
        onBack: notifier.handleBack,
        onOpenChat: notifier.openChat,
      );
    }
    if (nav.showChat) {
      return PlantChatScreen(
        plantId: nav.selectedPlantId,
        onBack: notifier.handleBack,
      );
    }

    return const SizedBox.shrink();
  }
}
