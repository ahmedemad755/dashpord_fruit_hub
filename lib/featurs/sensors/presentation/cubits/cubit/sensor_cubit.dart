import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/featurs/sensors/domain/repos/Sensor_repository.dart';
import 'package:fruitesdashboard/featurs/sensors/presentation/cubits/cubit/sensor_state.dart';

class SensorCubit extends Cubit<SensorState> {
  final SensorRepository repository;

  SensorCubit(this.repository) : super(SensorInitial());

  void monitorSensor() {
    emit(SensorLoading());
    repository.getSensorDataStream().listen((data) {
      emit(SensorDataUpdated(data));
    }).onError((error) {
      print("Sensor Error: $error"); // للدي باج
      emit(SensorError(error.toString()));
    });
  }
}