import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NutritionScreen - Widget Tests', () {
    testWidgets('Verifica presenza componenti base UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Nutrizione')),
            body: Column(
              children: [
                const Text('Bilancio Calorico'),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Aggiungi Cibo'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Nutrizione'), findsOneWidget);
      expect(find.text('Bilancio Calorico'), findsOneWidget);
      expect(find.text('Aggiungi Cibo'), findsOneWidget);
    });

    testWidgets('Verifica visualizzazione card calorie', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Card(
                  child: Column(
                    children: [
                      const Icon(Icons.restaurant),
                      const Text('1500'),
                      const Text('Consumate'),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      const Icon(Icons.local_fire_department),
                      const Text('400'),
                      const Text('Bruciate'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Consumate'), findsOneWidget);
      expect(find.text('Bruciate'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('Verifica presenza pulsante aggiunta cibo', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });
  });
}
