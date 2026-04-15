import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gossip_garden/features/plants/presentation/providers/plant_providers.dart';
import 'package:gossip_garden/features/plants/data/models/plant.dart';

final isGridViewProvider = StateProvider<bool>((ref) => true);
final favoritePlantsProvider = StateProvider<List<String>>((ref) => ['1', '2']);

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

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
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(context),
      body: _buildBody(ref),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () async {
          await HapticFeedback.lightImpact();
          if (!context.mounted) return;
          Navigator.of(context).pop();
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
      title: Text(
        'Ajustes',
        style: _textStyle(20, FontWeight.bold, _primaryColor),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(WidgetRef ref) {
    final plantsAsync = ref.watch(plantsProvider);
    return plantsAsync.when(
      data: (plants) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccountSection(),
              const SizedBox(height: 40),
              _buildFavoritePlantsSection(ref, plants),
              const SizedBox(height: 40),
              _buildConfigurationSection(),
              const SizedBox(height: 40),
              _buildSensorStatusSection(),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: _primaryColor),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e', style: _textStyle(16, FontWeight.w500)),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CUENTA',
          style: _textStyle(12, FontWeight.w700, Colors.black45),
        ),
        const SizedBox(height: 16),
        _buildSettingInputCard(
          label: 'NOMBRE',
          value: 'Gabriela Torres',
          showAction: false,
        ),
        const SizedBox(height: 16),
        _buildSettingInputCard(
          label: 'CORREO',
          value: 'gabriela@email.com',
          showAction: false,
        ),
        const SizedBox(height: 16),
        _buildSettingInputCard(
          label: 'CONTRASEÑA',
          value: '********',
          showAction: true,
          actionText: 'Cambiar',
        ),
        const SizedBox(height: 16),
        _buildSettingInputCard(
          label: 'CORREO DE RESPALDO',
          value: 'gabi.backup@email.com',
          showAction: false,
        ),
      ],
    );
  }

  Widget _buildSettingInputCard({
    required String label,
    required String value,
    required bool showAction,
    String? actionText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [_cardShadow],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: _textStyle(11, FontWeight.w600, Colors.black45),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: _textStyle(16, FontWeight.w500),
                ),
              ],
            ),
          ),
          if (showAction && actionText != null)
            TextButton(
              onPressed: () async {
                await HapticFeedback.lightImpact();
                // Handle password change
              },
              style: TextButton.styleFrom(
                foregroundColor: _primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                actionText,
                style: _textStyle(14, FontWeight.w600, _primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoritePlantsSection(WidgetRef ref, List<Plant> plants) {
    final isGridView = ref.watch(isGridViewProvider);
    final isGridViewNotifier = ref.read(isGridViewProvider.notifier);
    final favoritePlants = ref.watch(favoritePlantsProvider);
    final favoritePlantsNotifier = ref.read(favoritePlantsProvider.notifier);

    final favoriteCount = favoritePlants.length;
    final maxFavorites = 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLANTAS FAVORITAS',
                  style: _textStyle(12, FontWeight.w700, Colors.black45),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tus amigos verán estas plantas · $favoriteCount/$maxFavorites',
                  style: _textStyle(13, FontWeight.w500, Colors.grey.shade600),
                ),
              ],
            ),
            const Spacer(),
            _buildViewToggle(ref, isGridView, isGridViewNotifier),
          ],
        ),
        const SizedBox(height: 16),
        if (isGridView)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: plants.take(4).length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              final isFavorite = favoritePlants.contains(plant.id);
              return _buildFavoritePlantCard(
                plant: plant,
                isFavorite: isFavorite,
                onFavoriteToggle: () => _toggleFavorite(
                  ref,
                  plant.id,
                  favoritePlants,
                  favoritePlantsNotifier,
                ),
                isGrid: true,
              );
            },
          )
        else
          Column(
            children: plants.take(4).map((plant) {
              final isFavorite = favoritePlants.contains(plant.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildFavoritePlantCard(
                  plant: plant,
                  isFavorite: isFavorite,
                  onFavoriteToggle: () => _toggleFavorite(
                    ref,
                    plant.id,
                    favoritePlants,
                    favoritePlantsNotifier,
                  ),
                  isGrid: false,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildViewToggle(
    WidgetRef ref,
    bool isGridView,
    StateController<bool> isGridViewNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              if (isGridView) return;
              await HapticFeedback.mediumImpact();
              isGridViewNotifier.update((state) => true);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isGridView ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                boxShadow: isGridView
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                Icons.grid_view_rounded,
                size: 20,
                color: isGridView ? _primaryColor : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () async {
              if (!isGridView) return;
              await HapticFeedback.mediumImpact();
              isGridViewNotifier.update((state) => false);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: !isGridView ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                boxShadow: !isGridView
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                Icons.format_list_bulleted_rounded,
                size: 20,
                color: !isGridView ? _primaryColor : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritePlantCard({
    required Plant plant,
    required bool isFavorite,
    required VoidCallback onFavoriteToggle,
    required bool isGrid,
  }) {
    if (isGrid) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [_softShadow],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 12),
            Text(
              plant.name,
              style: _textStyle(14, FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              plant.species,
              style: _textStyle(12, FontWeight.w500, Colors.grey.shade500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                await HapticFeedback.lightImpact();
                onFavoriteToggle();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isFavorite ? _primaryColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isFavorite
                      ? null
                      : Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Icon(
                  Icons.star,
                  size: 18,
                  color: isFavorite ? Colors.white : Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [_cardShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: plant.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      plant.image,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.local_florist,
                    size: 25,
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
                  style: _textStyle(13, FontWeight.w500, Colors.grey.shade500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await HapticFeedback.lightImpact();
              onFavoriteToggle();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isFavorite ? _primaryColor : Colors.transparent,
                shape: BoxShape.circle,
                border: isFavorite
                    ? null
                    : Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Icon(
                Icons.star,
                size: 20,
                color: isFavorite ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONFIGURACIÓN',
          style: _textStyle(12, FontWeight.w700, Colors.black45),
        ),
        const SizedBox(height: 16),
        _buildConfigCard(
          icon: Icons.person_add_outlined,
          title: 'Invitar amigos',
          subtitle: 'Comparte tu jardín',
        ),
        const SizedBox(height: 16),
        _buildConfigCard(
          icon: Icons.lock_outlined,
          title: 'Privacidad',
          subtitle: 'Controla quién ve tu jardín',
        ),
      ],
    );
  }

  Widget _buildConfigCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [_cardShadow],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _textStyle(16, FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: _textStyle(13, FontWeight.w500, Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESTADO DE SENSORES',
          style: _textStyle(12, FontWeight.w700, Colors.black45),
        ),
        const SizedBox(height: 16),
        _buildSensorCard(
          plantName: 'Monstera',
          isConnected: true,
          batteryLevel: 85,
          status: 'Recopilando',
        ),
        const SizedBox(height: 16),
        _buildSensorCard(
          plantName: 'Cactus',
          isConnected: false,
          batteryLevel: 42,
          status: 'Inactivo',
        ),
      ],
    );
  }

  Widget _buildSensorCard({
    required String plantName,
    required bool isConnected,
    required int batteryLevel,
    required String status,
  }) {
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
                plantName,
                style: _textStyle(16, FontWeight.w600),
              ),
              const Spacer(),
              Icon(
                Icons.wifi,
                size: 16,
                color: isConnected ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                isConnected ? 'Conectado' : 'Desconectado',
                style: _textStyle(
                  12,
                  FontWeight.w500,
                  isConnected ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSensorInfo(
                icon: Icons.battery_charging_full_rounded,
                label: '$batteryLevel%',
                color: batteryLevel > 20 ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 24),
              _buildSensorInfo(
                icon: Icons.analytics_outlined,
                label: status,
                color: isConnected ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorInfo({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: _textStyle(14, FontWeight.w500, color),
        ),
      ],
    );
  }

  void _toggleFavorite(
    WidgetRef ref,
    String plantId,
    List<String> favoritePlants,
    StateController<List<String>> favoritePlantsNotifier,
  ) {
    final newFavorites = List<String>.from(favoritePlants);
    if (newFavorites.contains(plantId)) {
      newFavorites.remove(plantId);
    } else {
      if (newFavorites.length < 3) {
        newFavorites.add(plantId);
      }
    }
    favoritePlantsNotifier.state = newFavorites;
  }
}
