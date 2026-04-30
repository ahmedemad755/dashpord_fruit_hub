import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fruitesdashboard/featurs/sensors/data/models/sensor_model.dart';
import 'package:fruitesdashboard/featurs/sensors/domain/repos/Sensor_repository.dart';

class SensorRepositoryImpl implements SensorRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://fruit-hub-8689f-default-rtdb.firebaseio.com', 
  ).ref('PharmaGo');

  @override
  Stream<SensorModel> getSensorDataStream() {
    return _dbRef.onValue.map((event) {
      // 1. التأكد من أن الـ Snapshot والـ Value ليسوا null
      final snapshotValue = event.snapshot.value;
      
      if (snapshotValue == null) {
        // إرجاع موديل بقيم افتراضية بدلاً من رمي خطأ يكسر الـ Stream
        return SensorModel(temperature: 0.0, humidity: 0.0);
      }

      // 2. تحويل آمن للبيانات لتجنب DartError: Unexpected null value
      final Map<dynamic, dynamic> data = snapshotValue as Map<dynamic, dynamic>;
      
      return SensorModel.fromMap({
        'temperature': data['temperature'] ?? 0.0,
        'humidity': data['humidity'] ?? 0.0,
      });
    });
  }
}