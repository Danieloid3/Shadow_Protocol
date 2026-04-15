import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/plant_providers.dart';

import '../providers/navigation_provider.dart';
import '../../data/models/plant.dart';
import '../../data/models/plant_enums.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  static const _cardShadow = BoxShadow(
    color: Color(0x0A785A32),
    blurRadius: 20,
    offset: Offset(0, 8),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsProvider);
    final navNotifier = ref.read(navigationProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: AppBar(
        title: const Text('Conversaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: plantsAsync.when(
        data: (plants) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plants.length,
          itemBuilder: (context, index) =>
              _buildChatItem(context, plants[index], navNotifier),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildChatItem(
      BuildContext context, Plant plant, NavigationNotifier nav) {
    final lastMessage = _getLastMessagePreview(plant.id);
    final isOnline = plant.sensorStatus == SensorStatus.online;
    final unread = _hasUnread(plant.id);

    return GestureDetector(
      onTap: () => nav.openChat(plant.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [_cardShadow],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF4A6741).withOpacity(0.1),
                    image: plant.image.isNotEmpty
                        ? DecorationImage(
                            image: AssetImage(plant.image),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: plant.image.isEmpty
                      ? const Icon(Icons.local_florist,
                          size: 30, color: Color(0xFF4A6741))
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        plant.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatTime(DateTime.now().subtract(
                            Duration(minutes: plant.id.hashCode % 60))),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _moodColor(plant.mood).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          plant.mood.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _moodColor(plant.mood),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A6741).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${plant.health.toInt()}% salud',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A6741),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (unread)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A6741),
                            shape: BoxShape.circle,
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
    );
  }

  String _getLastMessagePreview(String plantId) {
    final messages = [
      '¡Hola! Mi humedad del suelo está al 28%, tengo sed.',
      '¡Gracias por regarme! Ahora estoy al 45%.',
      '¿Podrías moverme a un lugar con más luz?',
      'La temperatura está perfecta hoy 😊',
      'Mi sensor de luz detecta poca luminosidad.',
    ];
    final index = plantId.hashCode % messages.length;
    return messages[index];
  }

  bool _hasUnread(String plantId) {
    return plantId.hashCode % 3 == 0; // Simular algunos no leídos
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }

  Color _moodColor(PlantMood mood) {
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
