import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  static const _backgroundColor = Color(0xFFFDFCF8);
  static const _primaryColor = Color(0xFF4A6741);
  static const _cardShadow = BoxShadow(
    color: Color(0x0A785A32),
    blurRadius: 20,
  );

  TextStyle _textStyle(double fontSize, FontWeight fontWeight, [Color? color]) {
    return TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.black87,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 40),
              _buildBadgesSection(),
              const SizedBox(height: 40),
              _buildOptionsSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: _primaryColor.withOpacity(0.1),
          child: const Icon(
            Icons.person,
            size: 60,
            color: Color(0xFF4A6741),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Jardinero Digital',
          style: _textStyle(24, FontWeight.w800, _primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          '7 plantas conectadas',
          style: _textStyle(16, FontWeight.w500, Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🌱 Novato',
                style: _textStyle(14, FontWeight.w600, _primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '📡 3 sensores',
                style: _textStyle(14, FontWeight.w600, Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    final badges = [
      {'emoji': '🌿', 'title': 'Primera planta'},
      {'emoji': '💬', 'title': 'Conversador'},
      {'emoji': '📈', 'title': 'Científico'},
      {'emoji': '🤖', 'title': 'IA Amiga'},
      {'emoji': '💧', 'title': 'Regador'},
      {'emoji': '🌞', 'title': 'Luz perfecta'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logros',
          style: _textStyle(20, FontWeight.w800, _primaryColor),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return GestureDetector(
                onTap: () async {
                  await HapticFeedback.lightImpact();
                  // Handle badge tap
                },
                child: Container(
                  width: 100,
                  margin: EdgeInsets.only(
                    right: index == badges.length - 1 ? 0 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [_cardShadow],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        badge['emoji']!,
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge['title']!,
                        style: _textStyle(
                            12, FontWeight.w600, Colors.grey.shade800),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    final List<Map<String, dynamic>> options = [
      {
        'icon': Icons.favorite_border,
        'title': 'Favoritos',
        'color': Colors.red,
      },
      {
        'icon': Icons.sensors_outlined,
        'title': 'Sensores',
        'color': Colors.blue,
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notificaciones',
        'color': Colors.orange,
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Configuración',
        'color': Colors.grey,
      },
      {
        'icon': Icons.help_outline,
        'title': 'Ayuda',
        'color': Colors.green,
      },
      {
        'icon': Icons.exit_to_app,
        'title': 'Cerrar sesión',
        'color': Colors.black,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [_cardShadow],
      ),
      child: Column(
        children: options.map<Widget>((Map<String, dynamic> option) {
          final IconData icon = option['icon'] as IconData;
          final Color color = option['color'] as Color;
          final String title = option['title'] as String;
          return GestureDetector(
            onTap: () async {
              await HapticFeedback.lightImpact();
              // Handle option tap
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: option == options.last
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: _textStyle(16, FontWeight.w600),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
