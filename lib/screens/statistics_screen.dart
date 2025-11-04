import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:walk_and_fit/models/step_record.dart';
import 'package:walk_and_fit/models/workout_session.dart';
import 'package:walk_and_fit/services/database_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _dbService = DatabaseService.instance;
  List<StepRecord> _records = [];
  List<WorkoutSession> _workouts = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final records = await _dbService.getStepRecords(limit: 7);
    final stats = await _dbService.getStatistics();
    final workouts = await _dbService.getWorkoutSessions(limit: 10);
    setState(() {
      _records = records.reversed.toList();
      _stats = stats;
      _workouts = workouts.where((w) => w.endTime != null).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche'),
      ),
      body: _records.isEmpty
          ? const Center(child: Text('Nessun dato disponibile'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Riepilogo Totale',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow('Passi totali', '${_stats['totalSteps'] ?? 0}'),
                          _buildStatRow('Media giornaliera', '${(_stats['avgSteps'] ?? 0).toStringAsFixed(0)}'),
                          _buildStatRow('Calorie totali', '${(_stats['totalCalories'] ?? 0).toStringAsFixed(1)} kcal'),
                          _buildStatRow('Distanza totale', '${(_stats['totalDistance'] ?? 0).toStringAsFixed(2)} km'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ultimi 7 giorni',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 15000,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= _records.length) {
                                  return const Text('');
                                }
                                final record = _records[value.toInt()];
                                final date = DateFormat('dd/MM').format(
                                  DateTime.parse(record.date),
                                );
                                return Text(
                                  date,
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          _records.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: _records[index].steps.toDouble(),
                                color: _records[index].steps >= 10000
                                    ? Colors.green
                                    : Colors.blue,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cronologia Allenamenti',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_workouts.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Nessun allenamento registrato',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ..._workouts.map((workout) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.directions_run, color: Colors.white),
                            ),
                            title: Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(workout.startTime),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Durata: ${workout.formattedDuration}'),
                                Text('${workout.steps} passi - ${workout.distance.toStringAsFixed(2)} km'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Icon(Icons.speed, size: 16),
                                Text(
                                  workout.getAverageSpeedPerKm(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
