import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class PedometerService {
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();

  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  final _stepCountController = StreamController<int>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  Stream<int> get stepCountStream => _stepCountController.stream;
  Stream<String> get statusStream => _statusController.stream;

  int _initialSteps = 0;
  int _currentSteps = 0;

  Future<bool> requestPermissions() async {
    if (await Permission.activityRecognition.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> startListening() async {
    if (!await requestPermissions()) {
      _statusController.add('Permessi negati');
      return;
    }

    _stepCountSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );

    _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
      _onPedestrianStatusChanged,
      onError: _onPedestrianStatusError,
    );
  }

  void _onStepCount(StepCount event) {
    if (_initialSteps == 0) {
      _initialSteps = event.steps;
    }
    _currentSteps = event.steps - _initialSteps;
    _stepCountController.add(_currentSteps);
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    _statusController.add(event.status);
  }

  void _onStepCountError(error) {
    _statusController.add('Errore nel conteggio passi');
  }

  void _onPedestrianStatusError(error) {
    _statusController.add('Errore stato pedone');
  }

  void resetDailySteps() {
    _initialSteps = _currentSteps + _initialSteps;
    _currentSteps = 0;
    _stepCountController.add(0);
  }

  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    _stepCountController.close();
    _statusController.close();
  }
}
