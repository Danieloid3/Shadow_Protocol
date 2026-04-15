import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/plant_providers.dart';
import '../providers/chat_providers.dart';
import '../widgets/message_bubble.dart';
import '../widgets/telemetry_panel.dart';
import '../../data/models/plant.dart';
import '../../data/models/plant_enums.dart';

class PlantChatScreen extends ConsumerStatefulWidget {
  final String plantId;
  final VoidCallback onBack;

  const PlantChatScreen({
    super.key,
    required this.plantId,
    required this.onBack,
  });

  @override
  ConsumerState<PlantChatScreen> createState() => _PlantChatScreenState();
}

class _PlantChatScreenState extends ConsumerState<PlantChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  Plant? _plant;
  bool _telemetryExpanded = false;

  static const _backgroundColor = Color(0xFFFDFCF8);
  static const _primaryColor = Color(0xFF4A6741);
  static const _cardShadow = BoxShadow(
    color: Color(0x0A785A32),
    blurRadius: 20,
  );
  static const _headerHeight = 80.0;
  static const _bottomBarHeight = 80.0;

  TextStyle _textStyle(double fontSize, FontWeight fontWeight, [Color? color]) {
    return TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.black87,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    await HapticFeedback.lightImpact();
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatMessagesProvider(widget.plantId).notifier).addMessage(text);
    _textController.clear();
    setState(() {});

    // Simulate plant response after delay
    Future.delayed(const Duration(seconds: 1), () {
      ref.read(chatMessagesProvider(widget.plantId).notifier).addMessage(
            '¡Gracias por tu mensaje! Mi sensor de humedad marca ${_plant?.sensors.soilMoisture.toStringAsFixed(1)}%.',
            sender: 'plant',
            source: 'sensor',
            confidence: 'high',
          );
      _scrollToBottom();
    });
  }

  void _toggleTelemetry() async {
    await HapticFeedback.lightImpact();
    setState(() {
      _telemetryExpanded = !_telemetryExpanded;
    });
  }

  Widget _buildHeader(Plant plant) {
    return Container(
      height: _headerHeight,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await HapticFeedback.lightImpact();
              widget.onBack();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _primaryColor.withOpacity(0.1),
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF4A6741)),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: _primaryColor.withOpacity(0.1),
            radius: 20,
            child: Text(
              plant.name.substring(0, 1),
              style: _textStyle(16, FontWeight.w600, _primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plant.name,
                style: _textStyle(16, FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'En línea',
                    style: _textStyle(12, FontWeight.w500, Colors.green),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _toggleTelemetry,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                _telemetryExpanded ? Icons.expand_less : Icons.expand_more,
                color: _primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: BackdropFilter(
        filter: const ColorFilter.mode(Colors.white, BlendMode.srcOver),
        child: Container(
          height: _bottomBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [_cardShadow],
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle:
                          _textStyle(15, FontWeight.w500, Colors.grey.shade500),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                    style: _textStyle(15, FontWeight.w500),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [_cardShadow],
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantsAsync = ref.watch(plantsProvider);
    final messages = ref.watch(chatMessagesProvider(widget.plantId));

    return plantsAsync.when(
      data: (plants) {
        _plant = plants.firstWhere((p) => p.id == widget.plantId,
            orElse: () => plants.first);
        return Scaffold(
          backgroundColor: _backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(_plant!),
                    Expanded(
                      child: Column(
                        children: [
                          TelemetryPanel(
                            telemetryData: [
                              TelemetryData(
                                label: 'Humedad suelo',
                                value: _plant!.sensors.soilMoisture,
                                min: _plant!.comfortZones.soilMoisture.min,
                                max: _plant!.comfortZones.soilMoisture.max,
                                unit: '%',
                                icon: Icons.water_drop,
                                color: _primaryColor,
                              ),
                              TelemetryData(
                                label: 'Temperatura',
                                value: _plant!.sensors.temperature,
                                min: _plant!.comfortZones.temperature.min,
                                max: _plant!.comfortZones.temperature.max,
                                unit: '°C',
                                icon: Icons.thermostat,
                                color: Colors.orange,
                              ),
                              TelemetryData(
                                label: 'Luz',
                                value: _plant!.sensors.light,
                                min: _plant!.comfortZones.light.min,
                                max: _plant!.comfortZones.light.max,
                                unit: 'lux',
                                icon: Icons.light_mode,
                                color: Colors.amber,
                              ),
                              TelemetryData(
                                label: 'Humedad aire',
                                value: _plant!.sensors.humidity,
                                min: _plant!.comfortZones.humidity.min,
                                max: _plant!.comfortZones.humidity.max,
                                unit: '%',
                                icon: Icons.cloud,
                                color: Colors.blue,
                              ),
                            ],
                            initiallyExpanded: _telemetryExpanded,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(
                                  bottom: 100, left: 12, right: 12),
                              itemCount: messages.length,
                              itemBuilder: (context, index) =>
                                  MessageBubble(message: messages[index]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildBottomBar(),
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
}
