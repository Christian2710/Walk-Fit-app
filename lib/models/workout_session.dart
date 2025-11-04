class WorkoutSession {
  final int? id;
  final String date;
  final int startTime;
  final int? endTime;
  final int steps;
  final double distance;
  final double? averageSpeed;

  WorkoutSession({
    this.id,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.steps,
    required this.distance,
    this.averageSpeed,
  });

  int get duration => endTime != null ? endTime! - startTime : 0;

  String get formattedDuration {
    final totalSeconds = duration ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  double calculateAverageSpeed() {
    if (distance == 0 || duration == 0) return 0;
    final hours = duration / (1000 * 60 * 60);
    return distance / hours;
  }

  String getAverageSpeedPerKm() {
    if (distance == 0) return '--:--';
    final avgSpeed = calculateAverageSpeed();
    if (avgSpeed == 0) return '--:--';
    
    final minutesPerKm = 60 / avgSpeed;
    final minutes = minutesPerKm.floor();
    final seconds = ((minutesPerKm - minutes) * 60).round();
    
    return '${minutes}:${seconds.toString().padLeft(2, '0')} min/km';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'steps': steps,
      'distance': distance,
      'averageSpeed': averageSpeed,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      steps: map['steps'],
      distance: map['distance'],
      averageSpeed: map['averageSpeed'],
    );
  }
}
