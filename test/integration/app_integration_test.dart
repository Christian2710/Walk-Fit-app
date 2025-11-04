import 'package:flutter_test/flutter_test.dart';
import 'package:walk_and_fit/models/step_record.dart';
import 'package:walk_and_fit/models/workout_session.dart';
import 'package:walk_and_fit/models/food_item.dart';
import 'package:walk_and_fit/services/nutrition_api_service.dart';

void main() {
  group('Integration Tests - Flusso Completo Dati', () {
    test('Flusso completo: Passi -> Calorie -> Database', () {
      final nutritionService = NutritionApiService();
      
      final steps = 10000;
      final calories = nutritionService.calculateCaloriesFromSteps(steps);
      
      expect(calories, 400.0);
      
      final record = StepRecord(
        date: '2025-11-04',
        steps: steps,
        calories: calories,
        distance: steps * 0.0008,
      );
      
      expect(record.steps, 10000);
      expect(record.calories, 400.0);
      expect(record.distance, 8.0);
      
      final map = record.toMap();
      final restored = StepRecord.fromMap(map);
      
      expect(restored.steps, record.steps);
      expect(restored.calories, record.calories);
    });

    test('Flusso completo: Workout -> Calcolo Velocità -> Persistenza', () {
      final startTime = DateTime(2025, 11, 4, 10, 0).millisecondsSinceEpoch;
      final endTime = DateTime(2025, 11, 4, 11, 0).millisecondsSinceEpoch;
      
      final session = WorkoutSession(
        date: '2025-11-04',
        startTime: startTime,
        endTime: endTime,
        steps: 7500,
        distance: 6.0,
      );
      
      expect(session.duration, 3600000);
      expect(session.calculateAverageSpeed(), 6.0);
      expect(session.getAverageSpeedPerKm(), '10:00 min/km');
      
      final map = session.toMap();
      final restored = WorkoutSession.fromMap(map);
      
      expect(restored.duration, session.duration);
      expect(restored.calculateAverageSpeed(), session.calculateAverageSpeed());
    });

    test('Flusso completo: Ricerca Cibo -> Proporzione -> Salvataggio', () {
      final nutritionService = NutritionApiService();
      
      final foodData = nutritionService.searchLocalFoodDatabase('pasta');
      expect(foodData, isNotNull);
      
      final baseCalories = foodData!['calories'] as num;
      final baseServing = foodData['serving_size_g'] as num;
      
      final userQuantity = 200.0;
      final multiplier = userQuantity / baseServing;
      final actualCalories = baseCalories * multiplier;
      
      expect(actualCalories, 262.0);
      
      final food = FoodItem(
        date: '2025-11-04',
        name: 'pasta (200g)',
        calories: actualCalories.toDouble(),
        protein: (foodData['protein_g'] as num).toDouble() * multiplier,
        carbs: (foodData['carbohydrates_total_g'] as num).toDouble() * multiplier,
        fat: (foodData['fat_total_g'] as num).toDouble() * multiplier,
        servingSize: userQuantity,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      
      expect(food.calories, 262.0);
      expect(food.servingSize, 200.0);
      
      final map = food.toMap();
      final restored = FoodItem.fromMap(map);
      
      expect(restored.calories, food.calories);
      expect(restored.servingSize, food.servingSize);
    });

    test('Integrazione: Bilancio Calorico Completo', () {
      final caloriesConsumed = 2000.0;
      final stepsDone = 10000;
      final caloriesBurnedSteps = stepsDone * 0.04;
      
      expect(caloriesBurnedSteps, 400.0);
      
      final balance = caloriesConsumed - caloriesBurnedSteps;
      expect(balance, 1600.0);
      
      final stepsNeeded = balance / 0.04;
      expect(stepsNeeded, 40000.0);
      
      final minutesWalking = stepsNeeded / 100;
      expect(minutesWalking, 400.0);
    });

    test('Integrazione: Aggiustamento Runtime Workout', () {
      final targetPace = 6.0;
      final currentPace = 4.5;
      final initialStepsGoal = 10000;
      
      final ratio = currentPace / targetPace;
      final adjustedGoal = (initialStepsGoal / ratio).ceil();
      
      expect(adjustedGoal, greaterThan(initialStepsGoal));
      expect(adjustedGoal, 13334);
    });

    test('Integrazione: Sistema Messaggi Motivazionali', () {
      final nutritionService = NutritionApiService();
      
      final message1000 = nutritionService.getMotivationalMessage(1000);
      expect(message1000, contains('Inizia'));
      
      final message5000 = nutritionService.getMotivationalMessage(5000);
      expect(message5000.toLowerCase(), contains('benissimo'));
      
      final message10000 = nutritionService.getMotivationalMessage(10000);
      expect(message10000.toLowerCase(), contains('obiettivo'));
    });
  });
}
