import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gossip_garden/features/plants/presentation/providers/navigation_provider.dart';

class AnimatedBottomNav extends StatelessWidget {
  final TabId activeTab;
  final ValueChanged<TabId> onTabChange;

  const AnimatedBottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  static const _tabs = [
    (TabId.dashboard, Icons.home_rounded, 'Inicio'),
    (TabId.chat, Icons.chat_bubble_outline_rounded, 'Chat'),
    (TabId.garden, Icons.local_florist_rounded, 'Mi Jardín'),
    (TabId.profile, Icons.person_outline_rounded, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 90,
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border:
                Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.map((tab) {
              final isActive = activeTab == tab.$1;
              return GestureDetector(
                onTap: () async {
                  await HapticFeedback.lightImpact();
                  onTabChange(tab.$1);
                },
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isActive ? 1.0 : 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.$2,
                        size: 26,
                        color:
                            isActive ? const Color(0xFF4A6741) : Colors.black26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tab.$3,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? const Color(0xFF4A6741)
                              : Colors.black26,
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
