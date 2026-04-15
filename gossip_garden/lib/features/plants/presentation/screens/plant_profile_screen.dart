import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gossip_garden/features/plants/presentation/providers/plant_providers.dart';
import 'package:gossip_garden/features/plants/presentation/providers/navigation_provider.dart';
import 'package:gossip_garden/features/plants/data/models/plant.dart';
import 'package:gossip_garden/features/plants/data/models/plant_enums.dart';
import 'package:gossip_garden/features/plants/data/models/comfort_zones.dart';

class PlantProfileScreen extends ConsumerWidget {
  final String plantId;
  final VoidCallback onBack;

  const PlantProfileScreen({
    super.key,
    required this.plantId,
    required this.onBack,
  });

  static const _backgroundColor = Color(0xFFFDFCF8);
  static const _primaryColor = Color(0xFF4A6741);
  static const _yellowAccent = Color(0xFFFFD12B);
  static const _redAccent = Color(0xFFEF4444);
  static const _lightGrey = Color(0xFFF0F4EF);
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

    return plantsAsync.when(
      data: (plants) {
        final plant = plants.firstWhere(
          (p) => p.id == plantId,
          orElse: () => plants.first,
        );

        return Scaffold(
          backgroundColor: _backgroundColor,
          appBar: _buildAppBar(context, plant, navNotifier),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlantAvatarSection(plant),
                const SizedBox(height: 32),
                _buildHealthBanner(plant),
                const SizedBox(height: 32),
                _buildTelemetryGrid(plant),
                const SizedBox(height: 32),
                _buildChatFeedbackSection(),
                const SizedBox(height: 32),
                _buildLogActionSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: _primaryColor),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Text('Error: $e', style: _textStyle(16, FontWeight.w500)),
        ),
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    Plant plant,
    NavigationNotifier navNotifier,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () async {
          await HapticFeedback.lightImpact();
          onBack();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.black45,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            await HapticFeedback.lightImpact();
            navNotifier.openChat(plantId);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _yellowAccent,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 16,
                  color: Colors.black87,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hablar con ${plant.name}',
                  style: _textStyle(12, FontWeight.bold, Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantAvatarSection(Plant plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                image: plant.image.isNotEmpty
                    ? DecorationImage(
                        image: AssetImage(plant.image),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: plant.image.isEmpty
                  ? Icon(
                      Icons.local_florist,
                      size: 60,
                      color: _primaryColor,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [_softShadow],
                ),
                child: Icon(
                  Icons.wifi,
                  size: 16,
                  color: plant.sensorStatus == SensorStatus.online
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              '😥',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              plant.name,
              style: _textStyle(24, FontWeight.w800, _primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          plant.species,
          style: _textStyle(14, FontWeight.w500, Colors.black45),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _lightGrey,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Sedienta',
                style: _textStyle(10, FontWeight.w600, _primaryColor),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Precisión 85%',
                style: _textStyle(10, FontWeight.w600, Colors.black45),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthBanner(Plant plant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [_cardShadow],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '¿Cómo me siento?',
                style: _textStyle(14, FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${plant.health.toInt()}%',
                style: _textStyle(20, FontWeight.w800, _primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: plant.health / 100,
            backgroundColor: Colors.grey.shade200,
            color: _primaryColor,
            borderRadius: BorderRadius.circular(10),
            minHeight: 12,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 12,
                color: Colors.black45,
              ),
              const SizedBox(width: 6),
              Text(
                'Última actualización: 5 min',
                style: _textStyle(10, FontWeight.w500, Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid(Plant plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TELEMETRÍA',
          style: _textStyle(12, FontWeight.w700, Colors.black45),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            _buildTelemetryCard(
              icon: Icons.water_drop_rounded,
              title: 'Humedad',
              value: '45%',
              currentValue: plant.sensors.soilMoisture,
              comfortZone: plant.comfortZones.soilMoisture,
              showAlert: true,
              alertText: 'Fuera de zona hace 3 dias',
            ),
            _buildTelemetryCard(
              icon: Icons.thermostat_rounded,
              title: 'Temperatura',
              value: '22°C',
              currentValue: plant.sensors.temperature,
              comfortZone: plant.comfortZones.temperature,
              showAlert: false,
            ),
            _buildTelemetryCard(
              icon: Icons.water_drop_rounded,
              title: 'Humedad suelo',
              value: '68%',
              currentValue: plant.sensors.soilMoisture,
              comfortZone: plant.comfortZones.soilMoisture,
              showAlert: true,
              alertText: 'Fuera de zona hace 3 dias',
            ),
            _buildTelemetryCard(
              icon: Icons.light_mode_rounded,
              title: 'Luz',
              value: '850 lux',
              currentValue: plant.sensors.light,
              comfortZone: plant.comfortZones.light,
              showAlert: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTelemetryCard({
    required IconData icon,
    required String title,
    required String value,
    required double currentValue,
    required Range comfortZone,
    required bool showAlert,
    String? alertText,
  }) {
    final minComfort = comfortZone.min;
    final maxComfort = comfortZone.max;
    final isInComfortZone =
        currentValue >= minComfort && currentValue <= maxComfort;
    final comfortRangeWidth = maxComfort - minComfort;
    final totalRange = 100.0; // Assuming 0-100 scale
    final minPosition = minComfort / totalRange;
    final maxPosition = maxComfort / totalRange;
    final currentPosition = currentValue / totalRange;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [_cardShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: _primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: _textStyle(14, FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: _textStyle(28, FontWeight.w800, _primaryColor),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 20,
            child: Stack(
              children: [
                // Background track
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Comfort zone highlight
                Positioned(
                  left: minPosition * 100,
                  width: comfortRangeWidth,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Min comfort marker
                Positioned(
                  left: minPosition * 100 - 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8BBD0),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Max comfort marker
                Positioned(
                  left: maxPosition * 100 - 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8BBD0),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Current value indicator
                Positioned(
                  left: currentPosition * 100 - 6,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isInComfortZone ? _primaryColor : _redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${minComfort.toInt()}%',
                style: _textStyle(10, FontWeight.w500, Colors.black12),
              ),
              Text(
                '${maxComfort.toInt()}%',
                style: _textStyle(10, FontWeight.w500, Colors.black12),
              ),
            ],
          ),
          if (showAlert && alertText != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 12,
                  color: _redAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  alertText,
                  style: _textStyle(10, FontWeight.w500, _redAccent),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FEEDBACK',
          style: _textStyle(12, FontWeight.w700, Colors.black45),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [_cardShadow],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 20,
                    color: _primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lo que quiero contarte',
                    style: _textStyle(14, FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildChatBubble(
                'Mi humedad ha estado algo loca esta semana 😅',
              ),
              const SizedBox(height: 12),
              _buildChatBubble(
                '¡Estoy creciendo 12% más rápido que el mes pasado! 🌿',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_softShadow],
      ),
      child: Row(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 16,
            color: _primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: _textStyle(13, FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCIONES',
          style: _textStyle(12, FontWeight.w700, Colors.black45),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [_cardShadow],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar acción',
                style: _textStyle(14, FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: Icons.water_drop_rounded,
                    label: 'Riego',
                    color: _primaryColor,
                  ),
                  _buildActionButton(
                    icon: Icons.content_cut_rounded,
                    label: 'Poda',
                    color: const Color(0xFFE0F2F1),
                  ),
                  _buildActionButton(
                    icon: Icons.create_outlined,
                    label: 'Fertilicé',
                    color: const Color(0xFFE0F7FA),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.local_florist_rounded,
                    size: 12,
                    color: Colors.black45,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Cada acción me ayuda a conocerte mejor 🌿',
                      style: _textStyle(10, FontWeight.w500, Colors.black45),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.lightImpact();
        // Handle action button tap
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: label == 'Riego' ? Colors.white : Colors.black87,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: _textStyle(12, FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
