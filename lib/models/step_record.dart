class StepRecord {
  final int? id;
  final String date;
  final int steps;
  final double calories;
  final double distance;

  StepRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'steps': steps,
      'calories': calories,
      'distance': distance,
    };
  }

  factory StepRecord.fromMap(Map<String, dynamic> map) {
    return StepRecord(
      id: map['id'],
      date: map['date'],
      steps: map['steps'],
      calories: map['calories'],
      distance: map['distance'],
    );
  }
}
