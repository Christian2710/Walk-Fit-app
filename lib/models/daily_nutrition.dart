class DailyNutrition {
  final String date;
  final double caloriesConsumed;
  final double caloriesBurned;
  final double steps;
  final double workoutCalories;

  DailyNutrition({
    required this.date,
    required this.caloriesConsumed,
    required this.caloriesBurned,
    required this.steps,
    this.workoutCalories = 0,
  });

  double get totalCaloriesBurned => caloriesBurned + workoutCalories;

  double get calorieBalance => caloriesConsumed - totalCaloriesBurned;

  bool get isDeficit => calorieBalance < 0;

  double get stepsNeededToBalance {
    if (calorieBalance <= 0) return 0;
    return calorieBalance / 0.04;
  }

  double get minutesWalkingNeeded {
    return stepsNeededToBalance / 100;
  }

  String get balanceMessage {
    if (calorieBalance > 0) {
      return 'Hai ${calorieBalance.toStringAsFixed(0)} kcal da smaltire';
    } else if (calorieBalance < 0) {
      return 'Ottimo! Hai bruciato ${(-calorieBalance).toStringAsFixed(0)} kcal in più';
    } else {
      return 'Perfetto bilancio calorico!';
    }
  }
}
