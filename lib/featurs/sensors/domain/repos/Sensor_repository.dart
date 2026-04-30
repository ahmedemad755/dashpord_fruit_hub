import 'package:fruitesdashboard/featurs/sensors/domain/entity/Sensor_entity.dart';

abstract class SensorRepository {
  Stream<SensorEntity> getSensorDataStream();
}