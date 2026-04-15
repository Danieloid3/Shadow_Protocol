import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gossip_garden/features/plants/presentation/providers/plant_providers.dart';
import 'package:gossip_garden/features/plants/presentation/providers/navigation_provider.dart';
import 'package:gossip_garden/features/plants/data/models/plant.dart';
import 'package:gossip_garden/features/plants/data/models/plant_enums.dart';
import 'package:gossip_garden/features/plants/presentation/screens/profile_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _backgroundColor = Color(0xFFFDFCF8);
  static const _primaryColor = Color(0xFF4A6741);
  static const _cardShadow = BoxShadow(
    color: Color(0x0A785A32),
    blurRadius: 20,
    offset: Offset(0, 8),
  );
  static const _softShadow = BoxShadow(
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
    final plantsAsync = ref.watch(plantsProvider);
    final navNotifier = ref.read(navigationProvider.notifier);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: plantsAsync.when(
          data: (plants) {
            final favoritePlants = plants.take(3).toList();
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 40),
                    _buildAchievementsSection(context),
                    const SizedBox(height: 40),
                    _buildFavoritesSection(favoritePlants, navNotifier),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: _primaryColor),
          ),
          error: (e, _) => Center(
            child: Text('Error: $e', style: _textStyle(16, FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi Perfil',
                  style: _textStyle(24, FontWeight.w800, _primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jardinero Intermedio',
                  style: _textStyle(14, FontWeight.w500, Colors.black45),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                await HapticFeedback.lightImpact();
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileSettingsScreen(),
                  ),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _primaryColor.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xFF4A6741),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jardinero Digital',
                  style: _textStyle(18, FontWeight.w700, _primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Miembro desde Feb 2025',
                  style: _textStyle(14, FontWeight.w500, Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🌿 3 Logros',
                        style: _textStyle(13, FontWeight.w600, _primaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '💧 7 Plantas',
                        style: _textStyle(13, FontWeight.w600, Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    final achievements = [
      {
        'emoji': '🌧️',
        'title': 'Rey de la Lluvia',
        'description': 'Has regado tus plantas 10 veces a tiempo',
        'hasProgress': false,
      },
      {
        'emoji': '🔬',
        'title': 'Científico Botánico',
        'description': 'Completado 12 de 20 experimentos',
        'hasProgress': true,
        'progress': 12,
        'total': 20,
      },
      {
        'emoji': '💬',
        'title': 'Conversador',
        'description': 'Has tenido 50 conversaciones con tus plantas',
        'hasProgress': false,
      },
      {
        'emoji': '🌞',
        'title': 'Maestro de la Luz',
        'description': 'Mantenido luz ideal por 30 días seguidos',
        'hasProgress': false,
      },
      {
        'emoji': '🤖',
        'title': 'Amigo de la IA',
        'description': 'Usado recomendaciones de IA 25 veces',
        'hasProgress': false,
      },
      {
        'emoji': '📊',
        'title': 'Analista de Datos',
        'description': 'Revisado telemetría 100 veces',
        'hasProgress': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MIS LOGROS',
          style: _textStyle(12, FontWeight.w700, Colors.black45),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return GestureDetector(
                onTap: () async {
                  await HapticFeedback.lightImpact();
                  if (!context.mounted) return;
                  _showAchievementModal(context, achievement);
                },
                child: Container(
                  width: 140,
                  margin: EdgeInsets.only(
                    right: index == achievements.length - 1 ? 0 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [_softShadow],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              achievement['emoji'] as String,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              achievement['title'] as String,
                              style: _textStyle(
                                  14, FontWeight.w600, Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                            if (achievement['hasProgress'] as bool) ...[
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (achievement['progress'] as int) /
                                    (achievement['total'] as int),
                                backgroundColor: Colors.grey.shade200,
                                color: _primaryColor,
                                borderRadius: BorderRadius.circular(10),
                                minHeight: 6,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${achievement['progress']}/${achievement['total']}',
                                style: _textStyle(
                                    11, FontWeight.w500, Colors.grey.shade600),
                              ),
                            ],
                          ],
                        ),
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

  Widget _buildFavoritesSection(
      List<Plant> plants, NavigationNotifier navNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MIS FAVORITAS',
          style: _textStyle(12, FontWeight.w700, Colors.black45),
        ),
        const SizedBox(height: 16),
        Column(
          children: plants.map((plant) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () async {
                  await HapticFeedback.lightImpact();
                  navNotifier.selectPlant(plant.id);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [_cardShadow],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: plant.image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  plant.image,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.local_florist,
                                size: 30,
                                color: _primaryColor,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '🌿',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    plant.name,
                                    style: _textStyle(16, FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plant.species,
                              style: _textStyle(
                                  13, FontWeight.w500, Colors.grey.shade500),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      LinearProgressIndicator(
                                        value: plant.health / 100,
                                        backgroundColor: Colors.grey.shade200,
                                        color: plant.health > 70
                                            ? Colors.green
                                            : plant.health > 40
                                                ? Colors.orange
                                                : Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                        minHeight: 6,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Salud',
                                            style: _textStyle(11,
                                                FontWeight.w500, Colors.grey),
                                          ),
                                          Text(
                                            '${plant.health.toInt()}%',
                                            style: _textStyle(13,
                                                FontWeight.w700, _primaryColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _getMoodColor(plant.mood)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    plant.mood.name.toUpperCase(),
                                    style: _textStyle(10, FontWeight.w600,
                                        _getMoodColor(plant.mood)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showAchievementModal(
      BuildContext context, Map<String, dynamic> achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                achievement['emoji'] as String,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                achievement['title'] as String,
                style: _textStyle(24, FontWeight.w800, _primaryColor),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  achievement['description'] as String,
                  style: _textStyle(16, FontWeight.w500, Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              if (achievement['hasProgress'] as bool) ...[
                LinearProgressIndicator(
                  value: (achievement['progress'] as int) /
                      (achievement['total'] as int),
                  backgroundColor: Colors.grey.shade200,
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  '${achievement['progress'] as int}/${achievement['total'] as int} completado',
                  style: _textStyle(14, FontWeight.w600, Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await HapticFeedback.lightImpact();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Cerrar',
                    style: _textStyle(16, FontWeight.w600, Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getMoodColor(PlantMood mood) {
    switch (mood) {
      case PlantMood.happy:
        return Colors.green;
      case PlantMood.thirsty:
        return Colors.orange;
      case PlantMood.stressed:
        return Colors.red;
      case PlantMood.cold:
        return Colors.blue;
      case PlantMood.hot:
        return Colors.deepOrange;
      case PlantMood.perfect:
        return const Color(0xFF8BC34A);
    }
  }
}
