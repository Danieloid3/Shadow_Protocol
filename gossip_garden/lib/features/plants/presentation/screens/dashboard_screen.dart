import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/plant_providers.dart';
import '../widgets/plant_feed_card.dart';
import '../widgets/summary_banner.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(String) onSelectPlant;
  final Function(String) onOpenChat;
  final Function(String) onOpenFriendGarden;

  const DashboardScreen({
    super.key,
    required this.onSelectPlant,
    required this.onOpenChat,
    required this.onOpenFriendGarden,
  });

  static const _horizontalPadding = 24.0;
  static const _backgroundColor = Color(0xFFFDFCF8);
  static const _primaryColor = Color(0xFF4A6741);
  static const _accentYellow = Color(0xFFFFD12B);
  static const _softRed = Color(0xFFFEE2E2);
  static const _redAccent = Color(0xFFEF4444);
  static const _cardShadow = BoxShadow(
    color: Color(0x0A785A32),
    blurRadius: 20,
    offset: Offset(0, 8),
  );
  static const _pillShadow = BoxShadow(
    color: Color(0x0A785A32),
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  TextStyle _textStyle(double fontSize, FontWeight fontWeight, [Color? color]) {
    return TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.black87,
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buenos días, Gabriela 🌤️',
              style: _textStyle(14, FontWeight.w500, Colors.black45),
            ),
            const SizedBox(height: 8),
            Text(
              'Gossip Garden',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tus plantas tienen algo que contarte...',
              style: _textStyle(14, FontWeight.w400, Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: 16,
        ),
        child: SummaryBanner(onAction: () => onOpenChat('1')),
      ),
    );
  }

  Widget _buildStatusAlerts() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: 8,
        ),
        child: Column(
          children: [
            // Sensor Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [_pillShadow],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Esperando datos del sensor...',
                    style: _textStyle(14, FontWeight.w500, Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Error Pill
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _softRed,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [_cardShadow],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1 sensor con problemas',
                          style: _textStyle(16, FontWeight.w600, _redAccent),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Revisa la conexión para mantener tus plantas seguras',
                          style:
                              _textStyle(14, FontWeight.w400, Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () async {
                      await HapticFeedback.lightImpact();
                      // Handle review action
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Revisar',
                        style: _textStyle(14, FontWeight.w600, _redAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantFeedSection(AsyncValue<List<dynamic>> plantsAsync) {
    return plantsAsync.when(
      data: (plants) {
        return SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HOY TE DICEN...',
                    style: _textStyle(12, FontWeight.w700, Colors.black45),
                  ),
                  Row(
                    children: [
                      _buildIconButton(Icons.grid_view, () {}),
                      const SizedBox(width: 8),
                      _buildIconButton(Icons.list, () {}),
                    ],
                  ),
                ],
              ),
            ),
            ...plants.map((plant) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _horizontalPadding,
                    vertical: 8,
                  ),
                  child: _buildPlantFeedCard(plant),
                )),
          ]),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(color: _primaryColor),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text('Error: $e', style: _textStyle(16, FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantFeedCard(dynamic plant) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.lightImpact();
        onSelectPlant(plant.id);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [_cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(plant.mood).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(plant.mood),
                    style: _textStyle(
                        12, FontWeight.w600, _getStatusColor(plant.mood)),
                  ),
                ),
                const Spacer(),
                // Plant icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.local_florist, color: _primaryColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('🌿', style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    plant.insights.isNotEmpty
                        ? plant.insights.first
                        : '¡Todo está bien! 🌱',
                    style: _textStyle(16, FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRONTO TE PEDIRÁN...',
              style: _textStyle(12, FontWeight.w700, Colors.black45),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [_cardShadow],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            Icon(Icons.wb_sunny_outlined, color: _primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Necesitará luz',
                              style: _textStyle(16, FontWeight.w600),
                            ),
                            Text(
                              'en 2 días',
                              style: _textStyle(
                                  14, FontWeight.w400, Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await HapticFeedback.lightImpact();
                          // Handle reminder
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.notifications_none,
                                  size: 18, color: _primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Recordarme',
                                style: _textStyle(
                                    14, FontWeight.w600, _primaryColor),
                              ),
                            ],
                          ),
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

  Widget _buildFriendsGardenSection() {
    final friends = [
      {'name': 'Ana García', 'title': 'Jardinera Experta', 'progress': 0.85},
      {'name': 'Carlos Ruiz', 'title': 'Botánico Aficionado', 'progress': 0.65},
      {'name': 'María López', 'title': 'Cultivadora Urbana', 'progress': 0.92},
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EL JARDÍN DE MIS AMIGOS',
              style: _textStyle(12, FontWeight.w700, Colors.black45),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == friends.length - 1 ? 0 : 16,
                    ),
                    child: _buildFriendCard(friend),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [_cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: _primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend['name'],
                      style: _textStyle(14, FontWeight.w600),
                    ),
                    Text(
                      friend['title'],
                      style: _textStyle(12, FontWeight.w400, Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: friend['progress'],
                backgroundColor: Colors.grey.shade200,
                color: _primaryColor,
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${(friend['progress'] * 100).toInt()}% saludable',
                style: _textStyle(12, FontWeight.w500, Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await HapticFeedback.lightImpact();
                    // Handle like
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.favorite_border,
                        color: Colors.grey.shade600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    await HapticFeedback.lightImpact();
                    // Handle gift
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _accentYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Regalo',
                        style: _textStyle(14, FontWeight.w600, Colors.black87),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [_pillShadow],
        ),
        child: Icon(icon, size: 18, color: Colors.black54),
      ),
    );
  }

  Color _getStatusColor(dynamic mood) {
    if (mood.toString().contains('thirsty')) return Colors.green;
    if (mood.toString().contains('stressed')) return Colors.amber;
    if (mood.toString().contains('happy')) return Colors.blue;
    return Colors.grey;
  }

  String _getStatusText(dynamic mood) {
    if (mood.toString().contains('thirsty')) return 'Sedienta';
    if (mood.toString().contains('stressed')) return 'Estresada';
    if (mood.toString().contains('happy')) return 'Feliz';
    return 'Normal';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildHeaderSection(),
          _buildMainActionCard(),
          _buildStatusAlerts(),
          _buildPlantFeedSection(plantsAsync),
          _buildPredictionsSection(),
          _buildFriendsGardenSection(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
