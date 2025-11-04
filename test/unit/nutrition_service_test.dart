import 'package:flutter_test/flutter_test.dart';
import 'package:walk_and_fit/services/nutrition_api_service.dart';

void main() {
  group('NutritionApiService - Unit Tests', () {
    late NutritionApiService service;

    setUp(() {
      service = NutritionApiService();
    });

    test('calculateCaloriesFromSteps calcola correttamente le calorie', () {
      expect(service.calculateCaloriesFromSteps(0), 0);
      expect(service.calculateCaloriesFromSteps(1000), 40);
      expect(service.calculateCaloriesFromSteps(10000), 400);
      expect(service.calculateCaloriesFromSteps(5000), 200);
    });

    test('getMotivationalMessage ritorna messaggio corretto per range passi', () {
      expect(service.getMotivationalMessage(1000), contains('Inizia'));
      expect(service.getMotivationalMessage(3000), contains('Ottimo'));
      expect(service.getMotivationalMessage(6000), contains('benissimo'));
      expect(service.getMotivationalMessage(9000), contains('obiettivo'));
      expect(service.getMotivationalMessage(10500), contains('raggiunto'));
    });

    test('getHealthTips ritorna lista con consigli appropriati', () {
      final tipsLow = service.getHealthTips(2000);
      expect(tipsLow.length, greaterThan(0));
      expect(tipsLow.first, contains('bruciato'));

      final tipsMedium = service.getHealthTips(6000);
      expect(tipsMedium.length, greaterThan(0));

      final tipsHigh = service.getHealthTips(12000);
      expect(tipsHigh.length, greaterThan(0));
      expect(tipsHigh.any((tip) => tip.contains('idrat')), true);
    });

    test('searchLocalFoodDatabase trova cibi italiani nel database', () {
      final pasta = service.searchLocalFoodDatabase('pasta');
      expect(pasta, isNotNull);
      expect(pasta!['calories'], 131);

      final pollo = service.searchLocalFoodDatabase('pollo');
      expect(pollo, isNotNull);
      expect(pollo!['protein_g'], 31);

      final mela = service.searchLocalFoodDatabase('mela');
      expect(mela, isNotNull);
      expect(mela!['calories'], 52);
    });

    test('searchLocalFoodDatabase ricerca case-insensitive', () {
      final pasta1 = service.searchLocalFoodDatabase('PASTA');
      final pasta2 = service.searchLocalFoodDatabase('pasta');
      final pasta3 = service.searchLocalFoodDatabase('Pasta');

      expect(pasta1, isNotNull);
      expect(pasta2, isNotNull);
      expect(pasta3, isNotNull);
      expect(pasta1!['calories'], pasta2!['calories']);
    });

    test('searchLocalFoodDatabase ritorna null per cibo non esistente', () {
      final result = service.searchLocalFoodDatabase('ciboinesistente123');
      expect(result, isNull);
    });

    test('searchLocalFoodDatabase ricerca parziale funziona', () {
      final result = service.searchLocalFoodDatabase('pas');
      expect(result, isNotNull);
      expect(result!['name'], 'pasta');
    });
  });
}
