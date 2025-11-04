import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walk_and_fit/models/workout_session.dart';
import 'package:walk_and_fit/services/database_service.dart';
import 'package:walk_and_fit/services/pedometer_service.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _dbService = DatabaseService.instance;
  final _pedometerService = PedometerService();
  
  WorkoutSession? _activeSession;
  Timer? _timer;
  Timer? _runtimeTimer;
  int _elapsedTime = 0;
  int _steps = 0;
  int _startSteps = 0;
  double _distance = 0;
  bool _isRunning = false;
  
  String _activityType = 'walk';
  double _targetPace = 6.0;
  int _dynamicStepsGoal = 0;
  double _currentPace = 0;
  double _caloriesToBurn = 0;

  @override
  void initState() {
    super.initState();
    _checkActiveSession();
    _initPedometer();
    _loadCalorieTargets();
  }

  Future<void> _checkActiveSession() async {
    final session = await _dbService.getActiveWorkoutSession();
    if (session != null) {
      setState(() {
        _activeSession = session;
        _isRunning = true;
        _elapsedTime = DateTime.now().millisecondsSinceEpoch - session.startTime;
        _steps = session.steps;
        _distance = session.distance;
      });
      _startTimer();
    }
  }

  Future<void> _loadCalorieTargets() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final consumed = await _dbService.getTotalCaloriesConsumedByDate(today);
    final stepRecord = await _dbService.getStepRecordByDate(today);
    final burned = stepRecord?.calories ?? 0;

    final caloriesToBurn = consumed - burned;
    final stepsNeeded = caloriesToBurn > 0 ? (caloriesToBurn / 0.04).ceil() : 0;

    if (!mounted) return;
    setState(() {
      _caloriesToBurn = caloriesToBurn > 0 ? caloriesToBurn : 0;
      if (!_isRunning || stepsNeeded == 0) {
        _dynamicStepsGoal = stepsNeeded;
      }
    });
  }

  void _initPedometer() {
    _pedometerService.stepCountStream.listen((steps) {
      if (_isRunning) {
        setState(() {
          if (_startSteps == 0) {
            _startSteps = steps;
          }
          _steps = steps - _startSteps;
          _distance = _steps * 0.0008;
        });
        _updateActiveSession();
        _loadCalorieTargets();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime += 1000;
      });
    });

    _runtimeTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _adjustDynamicGoal();
    });
  }

  void _adjustDynamicGoal() async {
    if (!_isRunning) {
      await _loadCalorieTargets();
      return;
    }

    if (_elapsedTime <= 0 || _distance <= 0) {
      await _loadCalorieTargets();
      return;
    }

    final hours = _elapsedTime / (1000 * 60 * 60);
    _currentPace = _distance > 0 ? (60 / (_distance / hours)) : 0;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final consumed = await _dbService.getTotalCaloriesConsumedByDate(today);
    final stepRecord = await _dbService.getStepRecordByDate(today);
    final burned = stepRecord?.calories ?? 0;

    final calorieBalance = consumed - burned;
    final caloriesToBurn = calorieBalance > 0 ? calorieBalance.toDouble() : 0.0;

    if (caloriesToBurn == 0) {
      if (!mounted) return;
      setState(() {
        _caloriesToBurn = 0;
        _dynamicStepsGoal = 0;
      });
      return;
    }

    final stepsNeeded = (caloriesToBurn / 0.04).ceil();
    int adjustedGoal = stepsNeeded;

    if (_currentPace > 0 && _currentPace < _targetPace) {
      final ratio = _currentPace / _targetPace;
      adjustedGoal = (stepsNeeded / ratio).ceil();
    } else if (_currentPace > _targetPace) {
      final ratio = _targetPace / _currentPace;
      adjustedGoal = (stepsNeeded * ratio).ceil();
    }

    if (!mounted) return;
    setState(() {
      _caloriesToBurn = caloriesToBurn;
      _dynamicStepsGoal = adjustedGoal;
    });
  }

  Future<void> _startWorkout() async {
    final now = DateTime.now();
    final session = WorkoutSession(
      date: DateFormat('yyyy-MM-dd').format(now),
      startTime: now.millisecondsSinceEpoch,
      steps: 0,
      distance: 0,
    );

    final id = await _dbService.insertWorkoutSession(session);
    
    setState(() {
      _activeSession = WorkoutSession(
        id: id,
        date: session.date,
        startTime: session.startTime,
        steps: 0,
        distance: 0,
      );
      _isRunning = true;
      _elapsedTime = 0;
      _steps = 0;
      _startSteps = 0;
      _distance = 0;
    });

    _startTimer();
    await _loadCalorieTargets();
  }

  Future<void> _stopWorkout() async {
    if (_activeSession == null) return;

    _timer?.cancel();
    _runtimeTimer?.cancel();
    
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final finalSession = WorkoutSession(
      id: _activeSession!.id,
      date: _activeSession!.date,
      startTime: _activeSession!.startTime,
      endTime: endTime,
      steps: _steps,
      distance: _distance,
      averageSpeed: _distance > 0 && _elapsedTime > 0 
          ? _distance / (_elapsedTime / (1000 * 60 * 60)) 
          : 0,
    );

    await _dbService.updateWorkoutSession(finalSession);

    _showWorkoutSummary(finalSession);

    setState(() {
      _isRunning = false;
      _activeSession = null;
    });

    await _loadCalorieTargets();
  }

  Future<void> _updateActiveSession() async {
    if (_activeSession == null) return;

    final updatedSession = WorkoutSession(
      id: _activeSession!.id,
      date: _activeSession!.date,
      startTime: _activeSession!.startTime,
      steps: _steps,
      distance: _distance,
    );

    await _dbService.updateWorkoutSession(updatedSession);
  }

  void _showWorkoutSummary(WorkoutSession session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Allenamento Completato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Durata:', session.formattedDuration),
            _buildSummaryRow('Passi:', '${session.steps}'),
            _buildSummaryRow('Distanza:', '${session.distance.toStringAsFixed(2)} km'),
            _buildSummaryRow('Velocità media:', session.getAverageSpeedPerKm()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String _formatElapsedTime() {
    final totalSeconds = _elapsedTime ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getCurrentSpeed() {
    if (_distance == 0 || _elapsedTime == 0) return '--:-- min/km';
    
    final hours = _elapsedTime / (1000 * 60 * 60);
    final avgSpeed = _distance / hours;
    final minutesPerKm = 60 / avgSpeed;
    final minutes = minutesPerKm.floor();
    final seconds = ((minutesPerKm - minutes) * 60).round();
    
    return '${minutes}:${seconds.toString().padLeft(2, '0')} min/km';
  }

  Widget _buildActivitySelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActivityOption(
              'Camminata',
              'walk',
              6.0,
              Icons.directions_walk,
              Colors.green,
            ),
            _buildActivityOption(
              'Corsa Lenta',
              'jog',
              4.75,
              Icons.directions_run,
              Colors.orange,
            ),
            _buildActivityOption(
              'Corsa Veloce',
              'run',
              3.75,
              Icons.directions_run,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityOption(
    String label,
    String type,
    double pace,
    IconData icon,
    Color color,
  ) {
    final isSelected = _activityType == type;
    return GestureDetector(
      onTap: () {
        if (!_isRunning) {
          setState(() {
            _activityType = type;
            _targetPace = pace;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
            Text(
              '${pace.toInt()}:${((pace % 1) * 60).toInt().toString().padLeft(2, '0')} min/km',
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allenamento'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isRunning) _buildActivitySelector(),
                    if (!_isRunning) const SizedBox(height: 20),
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRunning ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        border: Border.all(
                          color: _isRunning ? Colors.green : Colors.grey,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _formatElapsedTime(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _isRunning ? Colors.green : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('Passi', '$_steps', Icons.directions_walk),
                        _buildStatCard('Distanza', '${_distance.toStringAsFixed(2)} km', Icons.route),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.speed, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  _getCurrentSpeed(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _caloriesToBurn > 0
                                  ? 'Calorie da bruciare oggi: ${_caloriesToBurn.toStringAsFixed(0)} kcal'
                                  : 'Obiettivo calorico giornaliero raggiunto',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _caloriesToBurn > 0 ? Colors.orange[800] : Colors.green[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_dynamicStepsGoal > 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Passi rimanenti: $_dynamicStepsGoal',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: !_isRunning
                                      ? Colors.blueGrey
                                      : (_currentPace < _targetPace ? Colors.green : Colors.orange),
                                ),
                              ),
                              if (_isRunning)
                                Text(
                                  _currentPace < _targetPace
                                      ? 'Ritmo superiore al target'
                                      : 'Aumenta il ritmo',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: FloatingActionButton(
                        onPressed: _isRunning ? _stopWorkout : _startWorkout,
                        backgroundColor: _isRunning ? Colors.red : Colors.green,
                        child: Icon(
                          _isRunning ? Icons.stop : Icons.play_arrow,
                          size: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isRunning ? 'Tocca per fermare' : 'Tocca per iniziare',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _runtimeTimer?.cancel();
    super.dispose();
  }
}
