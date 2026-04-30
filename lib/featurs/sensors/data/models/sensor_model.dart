
import 'package:fruitesdashboard/featurs/sensors/domain/entity/Sensor_entity.dart';

class SensorModel extends SensorEntity {
  SensorModel({required super.temperature, required super.humidity});

  factory SensorModel.fromMap(Map<dynamic, dynamic> map) {
    return SensorModel(
      temperature: (map['temperature'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
    );
  }
}