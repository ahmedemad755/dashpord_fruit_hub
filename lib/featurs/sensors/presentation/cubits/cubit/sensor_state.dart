import 'package:fruitesdashboard/featurs/sensors/domain/entity/Sensor_entity.dart';

abstract class SensorState {}

class SensorInitial extends SensorState {}
class SensorLoading extends SensorState {}
class SensorDataUpdated extends SensorState {
  final SensorEntity sensorData;
  SensorDataUpdated(this.sensorData);
}
class SensorError extends SensorState {
  final String message;
  SensorError(this.message);
}