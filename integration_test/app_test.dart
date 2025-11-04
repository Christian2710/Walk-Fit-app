import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:walk_and_fit/main.dart' as app;
import 'package:walk_and_fit/services/database_service.dart';
import 'package:walk_and_fit/models/step_record.dart';
import 'package:walk_and_fit/models/food_item.dart';
import 'package:intl/intl.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Test - App Android Completa', () {
    testWidgets('Test database SQLite su device Android', (WidgetTester tester) async {
      final dbService = DatabaseService.instance;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final record = StepRecord(
        date: today,
        steps: 5000,
        calories: 200,
        distance: 4.0,
      );

      await dbService.insertStepRecord(record);

      final retrieved = await dbService.getStepRecordByDate(today);
      expect(retrieved, isNotNull);
      expect(retrieved!.steps, 5000);
      expect(retrieved.calories, 200);
      expect(retrieved.distance, 4.0);

      await dbService.deleteStepRecord(today);
    });

    testWidgets('Test inserimento e recupero cibo dal database', (WidgetTester tester) async {
      final dbService = DatabaseService.instance;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final food = FoodItem(
        date: today,
        name: 'Test Pasta',
        calories: 300,
        protein: 10,
        carbs: 50,
        fat: 2,
        servingSize: 150,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final id = await dbService.insertFoodItem(food);
      expect(id, greaterThan(0));

      final foods = await dbService.getFoodItemsByDate(today);
      expect(foods.length, greaterThan(0));
      expect(foods.any((f) => f.name == 'Test Pasta'), true);

      await dbService.deleteFoodItem(id);
    });

    testWidgets('Test calcolo totale calorie consumate', (WidgetTester tester) async {
      final dbService = DatabaseService.instance;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final food1 = FoodItem(
        date: today,
        name: 'Cibo 1',
        calories: 200,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final food2 = FoodItem(
        date: today,
        name: 'Cibo 2',
        calories: 300,
        timestamp: DateTime.now().millisecondsSinceEpoch + 1000,
      );

      final id1 = await dbService.insertFoodItem(food1);
      final id2 = await dbService.insertFoodItem(food2);

      final total = await dbService.getTotalCaloriesConsumedByDate(today);
      expect(total, greaterThanOrEqualTo(500));

      await dbService.deleteFoodItem(id1);
      await dbService.deleteFoodItem(id2);
    });

    testWidgets('Test navigazione completa app Android', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Walk & Fit'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();
      expect(find.text('Nutrizione'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.timer));
      await tester.pumpAndSettle();
      expect(find.text('Allenamento'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      expect(find.text('Statistiche'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Walk & Fit'), findsOneWidget);
    });

    testWidgets('Test salvataggio e recupero obiettivo passi', (WidgetTester tester) async {
      final dbService = DatabaseService.instance;

      await dbService.setDailyStepGoal(12000);
      final goal = await dbService.getDailyStepGoal();
      expect(goal, 12000);

      await dbService.setDailyStepGoal(10000);
    });

    testWidgets('Test salvataggio peso utente', (WidgetTester tester) async {
      final dbService = DatabaseService.instance;

      await dbService.setUserWeight(75.5);
      final weight = await dbService.getUserWeight();
      expect(weight, 75.5);

      await dbService.setUserWeight(70.0);
    });

    testWidgets('Test statistiche aggregate database', (WidgetTester tester) async {
      final dbService = DatabaseService.instance;

      final stats = await dbService.getStatistics();
      expect(stats, isNotNull);
      expect(stats.containsKey('totalSteps'), true);
      expect(stats.containsKey('avgSteps'), true);
      expect(stats.containsKey('totalCalories'), true);
      expect(stats.containsKey('totalDistance'), true);
    });
  });
}
