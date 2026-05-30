import 'dart:async';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/featurs/sensors/domain/repos/Sensor_repository.dart';
import 'package:fruitesdashboard/featurs/sensors/presentation/cubits/cubit/sensor_state.dart';

class SensorCubit extends Cubit<SensorState> {
  SensorCubit(this.repository) : super(SensorInitial()) {
    _requestBrowserNotificationPermission();
    _prepareWebAudio();
  }

  final SensorRepository repository;

  static const String _alarmAssetPath =
      'assets/lib/core/assets/sounds/mixkit-classic-alarm-995.wav';
  static const String _alarmElementId = 'pharmago-temperature-alarm-audio';

  final double maxSafeTemperature = 8.0;

  html.AudioElement? _webAudioPlayer;
  StreamSubscription? _sensorSubscription;
  double? _silencedTemperature;
  double? _activeAlarmTemperature;
  double? _lastTemperature;

  bool isAlarmPlaying = false;

  void _prepareWebAudio() {
    _removeAlarmAudioElements();
    _webAudioPlayer = _createAlarmAudioElement();
  }

  html.AudioElement _createAlarmAudioElement() {
    final player = html.AudioElement(_alarmAssetPath)
      ..id = _alarmElementId
      ..loop = true
      ..preload = 'auto'
      ..style.display = 'none';

    html.document.body?.append(player);
    player.load();
    print('Web alarm audio element is ready.');
    return player;
  }

  void _removeAlarmAudioElements() {
    for (final element in html.document.querySelectorAll('audio')) {
      if (element is html.AudioElement &&
          (element.id == _alarmElementId ||
              element.src.contains('mixkit-classic-alarm-995.wav'))) {
        _forceStopAudioElement(element);
        element.remove();
      }
    }
  }

  void _forceStopAudioElement(html.AudioElement player) {
    try {
      player.pause();
      player.currentTime = 0;
      player.muted = false;
    } catch (_) {}
  }

  void _requestBrowserNotificationPermission() async {
    try {
      if (html.Notification.supported &&
          html.Notification.permission != 'granted') {
        await html.Notification.requestPermission();
      }
    } catch (e) {
      print('Browser notifications are not available: $e');
    }
  }

  void monitorSensor() {
    emit(SensorLoading());
    _sensorSubscription?.cancel();

    _sensorSubscription = repository.getSensorDataStream().listen((data) {
      _lastTemperature = data.temperature;

      if (data.temperature > maxSafeTemperature) {
        if (!_isSameTemperature(_silencedTemperature, data.temperature) &&
            !_isSameTemperature(_activeAlarmTemperature, data.temperature)) {
          _silencedTemperature = null;
          _triggerWebCriticalAlert(data.temperature);
        }
      } else {
        _silencedTemperature = null;
        _activeAlarmTemperature = null;
        _stopAlarmAudio();
      }

      if (!isClosed) {
        emit(SensorDataUpdated(data));
      }
    }, onError: (error) {
      print('Sensor Stream Error: $error');
      if (!isClosed) {
        emit(SensorError(error.toString()));
      }
    });
  }

  bool _isSameTemperature(double? first, double second) {
    if (first == null) return false;
    return (first - second).abs() < 0.01;
  }

  void _triggerWebCriticalAlert(double temperature) {
    _activeAlarmTemperature = temperature;

    _sendBrowserNotification(temperature);
    _startAlarmAudio();
  }

  void _sendBrowserNotification(double temperature) {
    try {
      if (html.Notification.supported &&
          html.Notification.permission == 'granted') {
        html.Notification(
          'تحذير حرج من PharmaGo',
          body:
              'ارتفاع حرارة ثلاجة الأدوية إلى $temperature°C! الأدوية في خطر التلف.',
        );
      }
    } catch (e) {
      print('Error sending browser notification: $e');
    }
  }

  void _startAlarmAudio() {
    try {
      final player = _webAudioPlayer ?? _createAlarmAudioElement();
      _webAudioPlayer = player;

      isAlarmPlaying = true;
      player
        ..src = _alarmAssetPath
        ..loop = true
        ..muted = false
        ..currentTime = 0;

      unawaited(
        player.play().catchError((error) {
          print('Browser blocked alarm audio until user interaction: $error');
        }),
      );
    } catch (e) {
      print('Alarm audio play error: $e');
    }
  }

  void retryPlayAlarmIfNeeded() {
    // Kept for old UI calls, but intentionally does nothing.
    // Re-playing from rebuilds/listeners can restart the alarm after it is stopped.
  }

  void _stopAlarmAudio({bool clearActiveAlarm = true}) {
    final player = _webAudioPlayer;
    isAlarmPlaying = false;
    if (clearActiveAlarm) {
      _activeAlarmTemperature = null;
    }

    if (player != null) {
      _forceStopAudioElement(player);
      player.remove();
    }

    _removeAlarmAudioElements();
    _webAudioPlayer = null;
  }

  void stopAlertSound() {
    try {
      final currentTemperature = state is SensorDataUpdated
          ? (state as SensorDataUpdated).sensorData.temperature
          : _lastTemperature;

      _stopAlarmAudio();
      _silencedTemperature = currentTemperature;

      if (state is SensorDataUpdated && !isClosed) {
        emit(SensorDataUpdated((state as SensorDataUpdated).sensorData));
      }

      print('Alarm stopped by pharmacist.');
    } catch (e) {
      print('Error stopping alarm audio: $e');
    }
  }

  @override
  Future<void> close() async {
    await _sensorSubscription?.cancel();
    _stopAlarmAudio();
    return super.close();
  }
}
