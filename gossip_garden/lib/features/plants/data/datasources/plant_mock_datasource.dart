import 'package:gossip_garden/features/plants/data/datasources/plant_datasource.dart';
import 'package:gossip_garden/features/plants/data/models/plant.dart';
import 'package:gossip_garden/features/plants/data/models/plant_enums.dart';
import 'package:gossip_garden/features/plants/data/models/comfort_zones.dart';
import 'package:gossip_garden/features/plants/data/models/sensors.dart';

class PlantMockDatasource implements PlantDatasource {
  @override
  Future<List<Plant>> getPlants() async {
    // Pequeño delay para que el loading del UI sea visible
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Plant(
        id: '1',
        name: 'Monstera',
        species: 'Monstera Deliciosa',
        image: '',
        personality: PlantPersonality.wise,
        health: 78.0,
        mood: PlantMood.thirsty,
        lastWatered: '2 días',
        sensors: const Sensors(
          humidity: 45.0,
          temperature: 22.0,
          light: 650.0,
          soilMoisture: 28.0,
        ),
        sensorStatus: SensorStatus.online,
        confidence: ConfidenceLevel.high,
        actions: const [], // Lista vacía de PlantAction
        insights: const ['Mi humedad ha estado algo loca 😅'],
        comfortZones: const ComfortZones(
          // CORRECCIÓN: Range usa constructor posicional (min, max)
          humidity: Range(50.0, 70.0),
          temperature: Range(18.0, 27.0),
          light: Range(400.0, 1000.0),
          soilMoisture: Range(40.0, 65.0),
        ),
      ),
      Plant(
        id: '2',
        name: 'Paco',
        species: 'Cactus',
        image: '',
        personality: PlantPersonality.dramatic,
        health: 95.0,
        mood: PlantMood.happy,
        lastWatered: '15 días',
        sensors: const Sensors(
          humidity: 20.0,
          temperature: 30.0,
          light: 1200.0,
          soilMoisture: 10.0,
        ),
        sensorStatus: SensorStatus.online,
        confidence: ConfidenceLevel.high,
        actions: const [],
        insights: const ['¿Más sol? Me encanta ser un desierto viviente.'],
        comfortZones: const ComfortZones(
          humidity: Range(10.0, 30.0),
          temperature: Range(20.0, 35.0),
          light: Range(800.0, 2000.0),
          soilMoisture: Range(5.0, 15.0),
        ),
      ),
    ];
  }
}
