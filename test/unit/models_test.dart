import 'package:flutter_test/flutter_test.dart';
import 'package:walk_and_fit/models/workout_session.dart';
import 'package:walk_and_fit/models/daily_nutrition.dart';
import 'package:walk_and_fit/models/step_record.dart';
import 'package:walk_and_fit/models/food_item.dart';

void main() {
  group('WorkoutSession - Unit Tests', () {
    test('duration calcola correttamente la durata', () {
      final session = WorkoutSession(
        date: '2025-11-04',
        startTime: 1000000,
        endTime: 1600000,
        steps: 5000,
        distance: 4.0,
      );

      expect(session.duration, 600000);
    });

    test('formattedDuration formatta correttamente', () {
      final session1 = WorkoutSession(
        date: '2025-11-04',
        startTime: 0,
        endTime: 3665000,
        steps: 5000,
        distance: 4.0,
      );

      expect(session1.formattedDuration, '1h 1m 5s');

      final session2 = WorkoutSession(
        date: '2025-11-04',
        startTime: 0,
        endTime: 125000,
        steps: 1000,
        distance: 0.8,
      );

      expect(session2.formattedDuration, '2m 5s');
    });

    test('calculateAverageSpeed calcola velocità correttamente', () {
      final session = WorkoutSession(
        date: '2025-11-04',
        startTime: 0,
        endTime: 3600000,
        steps: 7500,
        distance: 6.0,
      );

      expect(session.calculateAverageSpeed(), 6.0);
    });

    test('getAverageSpeedPerKm formatta passo per km', () {
      final session = WorkoutSession(
        date: '2025-11-04',
        startTime: 0,
        endTime: 3600000,
        steps: 7500,
        distance: 6.0,
      );

      expect(session.getAverageSpeedPerKm(), '10:00 min/km');
    });

    test('toMap e fromMap serializzazione/deserializzazione', () {
      final original = WorkoutSession(
        id: 1,
        date: '2025-11-04',
        startTime: 1000000,
        endTime: 2000000,
        steps: 5000,
        distance: 4.0,
        averageSpeed: 5.5,
      );

      final map = original.toMap();
      final restored = WorkoutSession.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.date, original.date);
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
      expect(restored.steps, original.steps);
      expect(restored.distance, original.distance);
      expect(restored.averageSpeed, original.averageSpeed);
    });
  });

  group('DailyNutrition - Unit Tests', () {
    test('totalCaloriesBurned somma correttamente', () {
      final nutrition = DailyNutrition(
        date: '2025-11-04',
        caloriesConsumed: 2000,
        caloriesBurned: 300,
        steps: 7500,
        workoutCalories: 150,
      );

      expect(nutrition.totalCaloriesBurned, 450);
    });

    test('calorieBalance calcola differenza corretta', () {
      final nutrition = DailyNutrition(
        date: '2025-11-04',
        caloriesConsumed: 2000,
        caloriesBurned: 400,
        steps: 10000,
      );

      expect(nutrition.calorieBalance, 1600);
    });

    test('isDeficit identifica correttamente deficit/surplus', () {
      final deficit = DailyNutrition(
        date: '2025-11-04',
        caloriesConsumed: 1500,
        caloriesBurned: 2000,
        steps: 50000,
      );

      expect(deficit.isDeficit, true);

      final surplus = DailyNutrition(
        date: '2025-11-04',
        caloriesConsumed: 2000,
        caloriesBurned: 400,
        steps: 10000,
      );

      expect(surplus.isDeficit, false);
    });

    test('stepsNeededToBalance calcola passi necessari', () {
      final nutrition = DailyNutrition(
        date: '2025-11-04',
        caloriesConsumed: 2000,
        caloriesBurned: 400,
        steps: 10000,
      );

      expect(nutrition.stepsNeededToBalance, (1600 / 0.04).ceil());
    });

    test('minutesWalkingNeeded calcola minuti necessari', () {
      final nutrition = DailyNutrition(
        date: '2025-11-04',
        caloriesConsumed: 2000,
        caloriesBurned: 400,
        steps: 10000,
      );

      final expectedSteps = (1600 / 0.04).ceil();
      final expectedMinutes = expectedSteps / 100;
      expect(nutrition.minutesWalkingNeeded, expectedMinutes);
    });

    test('balanceMessage ritorna messaggio corretto', () {
      final surplus = DailyNutrition(
        date: '2025-11-04',
        caloriesConsumed: 2000,
        caloriesBurned: 400,
        steps: 10000,
      );

      expect(surplus.balanceMessage, contains('smaltire'));

      final deficit = DailyNutrition(
        date: '2025-11-04',
        caloriesConsumed: 1500,
        caloriesBurned: 2000,
        steps: 50000,
      );

      expect(deficit.balanceMessage, contains('bruciato'));
    });
  });

  group('StepRecord e FoodItem - Unit Tests', () {
    test('StepRecord serializzazione funziona', () {
      final record = StepRecord(
        id: 1,
        date: '2025-11-04',
        steps: 10000,
        calories: 400,
        distance: 8.0,
      );

      final map = record.toMap();
      final restored = StepRecord.fromMap(map);

      expect(restored.steps, record.steps);
      expect(restored.calories, record.calories);
      expect(restored.distance, record.distance);
    });

    test('FoodItem serializzazione funziona', () {
      final food = FoodItem(
        id: 1,
        date: '2025-11-04',
        name: 'Pasta',
        calories: 400,
        protein: 12,
        carbs: 75,
        fat: 2,
        servingSize: 200,
        timestamp: 1699110000000,
      );

      final map = food.toMap();
      final restored = FoodItem.fromMap(map);

      expect(restored.name, food.name);
      expect(restored.calories, food.calories);
      expect(restored.servingSize, food.servingSize);
    });
  });
}
