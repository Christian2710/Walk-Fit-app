import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walk_and_fit/models/step_record.dart';
import 'package:walk_and_fit/services/database_service.dart';
import 'package:walk_and_fit/services/nutrition_api_service.dart';
import 'package:walk_and_fit/services/pedometer_service.dart';
import 'package:walk_and_fit/screens/statistics_screen.dart';
import 'package:walk_and_fit/screens/workout_screen.dart';
import 'package:walk_and_fit/screens/nutrition_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pedometerService = PedometerService();
  final _nutritionService = NutritionApiService();
  final _dbService = DatabaseService.instance;

  int _steps = 0;
  String _status = 'Inizializzazione...';
  double _calories = 0;
  double _distance = 0;
  int _goalSteps = 10000;
  int _dynamicGoalSteps = 10000;
  double _caloriesConsumed = 0;
  String _suggestedPace = '--:--';

  @override
  void initState() {
    super.initState();
    _loadGoal();
    _initPedometer();
    _loadTodayData();
  }

  Future<void> _loadGoal() async {
    final goal = await _dbService.getDailyStepGoal();
    setState(() {
      _goalSteps = goal;
    });
  }

  Future<void> _initPedometer() async {
    await _pedometerService.startListening();

    _pedometerService.stepCountStream.listen((steps) {
      setState(() {
        _steps = steps;
        _calories = _nutritionService.calculateCaloriesFromSteps(steps);
        _distance = steps * 0.0008;
      });
      _saveTodayData();
    });

    _pedometerService.statusStream.listen((status) {
      setState(() {
        _status = status;
      });
    });
  }

  Future<void> _loadTodayData() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final record = await _dbService.getStepRecordByDate(today);
    if (record != null) {
      setState(() {
        _steps = record.steps;
        _calories = record.calories;
        _distance = record.distance;
      });
    }
    await _updateDynamicGoal();
  }

  Future<void> _updateDynamicGoal() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final consumed = await _dbService.getTotalCaloriesConsumedByDate(today);
    
    setState(() {
      _caloriesConsumed = consumed;
      final calorieBalance = consumed - _calories;
      
      if (calorieBalance > 0) {
        final stepsNeeded = (calorieBalance / 0.04).ceil();
        _dynamicGoalSteps = _steps + stepsNeeded;
        
        final remainingDistance = stepsNeeded * 0.0008;
        final estimatedMinutes = stepsNeeded / 100;
        if (remainingDistance > 0) {
          final minutesPerKm = estimatedMinutes / remainingDistance;
          final mins = minutesPerKm.floor();
          final secs = ((minutesPerKm - mins) * 60).round();
          _suggestedPace = '$mins:${secs.toString().padLeft(2, '0')} min/km';
        }
      } else {
        _dynamicGoalSteps = _goalSteps;
        _suggestedPace = '6:00 min/km';
      }
    });
  }

  Future<void> _saveTodayData() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final record = StepRecord(
      date: today,
      steps: _steps,
      calories: _calories,
      distance: _distance,
    );
    await _dbService.insertStepRecord(record);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _steps / _dynamicGoalSteps;
    final motivationMessage = _nutritionService.getMotivationalMessage(_steps);
    final healthTips = _nutritionService.getHealthTips(_steps);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Walk & Fit'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NutritionScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: progress > 1 ? 1 : progress,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1 ? Colors.green : Colors.blue,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '$_steps',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'passi',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Obiettivo: $_dynamicGoalSteps passi',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: _showGoalDialog,
                            ),
                          ],
                        ),
                        if (_caloriesConsumed > _calories)
                          Column(
                            children: [
                              Text(
                                'Passo suggerito: $_suggestedPace',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${(_dynamicGoalSteps - _steps)} passi rimanenti',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      motivationMessage,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.local_fire_department,
                          '${_calories.toStringAsFixed(1)} kcal',
                          'Calorie',
                        ),
                        _buildStatItem(
                          Icons.route,
                          '${_distance.toStringAsFixed(2)} km',
                          'Distanza',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consigli per la salute',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...healthTips.map((tip) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 20, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text(tip)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.orange),
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
    );
  }

  void _showGoalDialog() {
    final controller = TextEditingController(text: _goalSteps.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica Obiettivo'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Passi giornalieri',
            suffixText: 'passi',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              final newGoal = int.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                await _dbService.setDailyStepGoal(newGoal);
                setState(() {
                  _goalSteps = newGoal;
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pedometerService.dispose();
    super.dispose();
  }
}
