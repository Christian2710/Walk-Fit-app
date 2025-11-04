import 'dart:convert';
import 'package:http/http.dart' as http;

class NutritionApiService {
  static const String _apiNinjasKey = 'Qb7FjipngyhSRSGkcfgKUA==h7wyv2LzhMa25f8Y';
  static const String _apiNinjasBaseUrl = 'https://api.api-ninjas.com/v1';

  Future<Map<String, dynamic>?> getNutritionInfo(String foodName) async {
    final localResult = searchLocalFoodDatabase(foodName);
    if (localResult != null) {
      return localResult;
    }

    try {
      final response = await http.get(
        Uri.parse('$_apiNinjasBaseUrl/nutrition?query=$foodName'),
        headers: {'X-Api-Key': _apiNinjasKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          return data[0];
        }
      }
    } catch (e) {
      return null;
    }

    return null;
  }



  Map<String, dynamic>? searchLocalFoodDatabase(String foodName) {
    final localDatabase = {
      'mela': {'calories': 52, 'protein': 0.3, 'carbs': 14, 'fat': 0.2, 'serving': 100},
      'banana': {'calories': 89, 'protein': 1.1, 'carbs': 23, 'fat': 0.3, 'serving': 100},
      'pasta': {'calories': 131, 'protein': 5, 'carbs': 25, 'fat': 1.1, 'serving': 100},
      'riso': {'calories': 130, 'protein': 2.7, 'carbs': 28, 'fat': 0.3, 'serving': 100},
      'pane': {'calories': 265, 'protein': 9, 'carbs': 49, 'fat': 3.2, 'serving': 100},
      'pollo': {'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6, 'serving': 100},
      'manzo': {'calories': 250, 'protein': 26, 'carbs': 0, 'fat': 15, 'serving': 100},
      'pesce': {'calories': 206, 'protein': 22, 'carbs': 0, 'fat': 12, 'serving': 100},
      'uova': {'calories': 155, 'protein': 13, 'carbs': 1.1, 'fat': 11, 'serving': 100},
      'latte': {'calories': 42, 'protein': 3.4, 'carbs': 5, 'fat': 1, 'serving': 100},
      'formaggio': {'calories': 402, 'protein': 25, 'carbs': 1.3, 'fat': 33, 'serving': 100},
      'yogurt': {'calories': 59, 'protein': 3.5, 'carbs': 4.7, 'fat': 3.3, 'serving': 100},
      'patate': {'calories': 77, 'protein': 2, 'carbs': 17, 'fat': 0.1, 'serving': 100},
      'carote': {'calories': 41, 'protein': 0.9, 'carbs': 10, 'fat': 0.2, 'serving': 100},
      'pomodoro': {'calories': 18, 'protein': 0.9, 'carbs': 3.9, 'fat': 0.2, 'serving': 100},
      'insalata': {'calories': 15, 'protein': 1.4, 'carbs': 2.9, 'fat': 0.2, 'serving': 100},
      'pizza': {'calories': 266, 'protein': 11, 'carbs': 33, 'fat': 10, 'serving': 100},
      'biscotti': {'calories': 502, 'protein': 6.3, 'carbs': 68, 'fat': 24, 'serving': 100},
      'cioccolato': {'calories': 546, 'protein': 4.9, 'carbs': 61, 'fat': 31, 'serving': 100},
      'gelato': {'calories': 207, 'protein': 3.5, 'carbs': 24, 'fat': 11, 'serving': 100},
      'arance': {'calories': 47, 'protein': 0.9, 'carbs': 12, 'fat': 0.1, 'serving': 100},
      'fragole': {'calories': 32, 'protein': 0.7, 'carbs': 7.7, 'fat': 0.3, 'serving': 100},
      'pesche': {'calories': 39, 'protein': 0.9, 'carbs': 10, 'fat': 0.3, 'serving': 100},
      'carne': {'calories': 250, 'protein': 26, 'carbs': 0, 'fat': 15, 'serving': 100},
      'verdure': {'calories': 20, 'protein': 1, 'carbs': 4, 'fat': 0.2, 'serving': 100},
      'cereali': {'calories': 379, 'protein': 8, 'carbs': 84, 'fat': 1.4, 'serving': 100},
      'legumi': {'calories': 116, 'protein': 9, 'carbs': 20, 'fat': 0.4, 'serving': 100},
      'tonno': {'calories': 144, 'protein': 30, 'carbs': 0, 'fat': 1, 'serving': 100},
      'salmone': {'calories': 208, 'protein': 20, 'carbs': 0, 'fat': 13, 'serving': 100},
      'prosciutto': {'calories': 145, 'protein': 22, 'carbs': 0.5, 'fat': 6, 'serving': 100},
      'nutella': {'calories': 539, 'protein': 6, 'carbs': 58, 'fat': 31, 'serving': 100},
      'olio': {'calories': 884, 'protein': 0, 'carbs': 0, 'fat': 100, 'serving': 100},
      'burro': {'calories': 717, 'protein': 0.9, 'carbs': 0.1, 'fat': 81, 'serving': 100},
      'zucchero': {'calories': 387, 'protein': 0, 'carbs': 100, 'fat': 0, 'serving': 100},
      'caffè': {'calories': 2, 'protein': 0.1, 'carbs': 0, 'fat': 0, 'serving': 100},
      'tè': {'calories': 1, 'protein': 0, 'carbs': 0.3, 'fat': 0, 'serving': 100},
      'acqua': {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0, 'serving': 100},
      'vino': {'calories': 83, 'protein': 0.1, 'carbs': 2.6, 'fat': 0, 'serving': 100},
      'birra': {'calories': 43, 'protein': 0.5, 'carbs': 3.6, 'fat': 0, 'serving': 100},
    };

    final searchKey = foodName.toLowerCase().trim();
    
    for (var entry in localDatabase.entries) {
      if (entry.key.contains(searchKey) || searchKey.contains(entry.key)) {
        return {
          'name': entry.key,
          'calories': entry.value['calories'],
          'protein_g': entry.value['protein'],
          'carbohydrates_total_g': entry.value['carbs'],
          'fat_total_g': entry.value['fat'],
          'serving_size_g': entry.value['serving'],
        };
      }
    }

    return null;
  }

  double calculateCaloriesFromSteps(int steps) {
    return steps * 0.04;
  }

  String getMotivationalMessage(int steps) {
    if (steps < 2000) {
      return "Inizia a muoverti. Ogni passo conta.";
    } else if (steps < 5000) {
      return "Ottimo inizio. Continua così.";
    } else if (steps < 8000) {
      return "Stai andando benissimo. Quasi all'obiettivo.";
    } else if (steps < 10000) {
      return "Fantastico. Sei vicino all'obiettivo.";
    } else {
      return "Eccellente. Hai raggiunto l'obiettivo.";
    }
  }

  List<String> getHealthTips(int steps) {
    final tips = <String>[];
    final calories = calculateCaloriesFromSteps(steps);
    
    tips.add('Hai bruciato circa ${calories.toStringAsFixed(1)} kcal');
    
    if (steps >= 10000) {
      tips.add('Ottima attività svolta. Ricordati di idratarti adeguatamente');
      tips.add('Considera di eseguire esercizi di stretching post-camminata');
    } else if (steps >= 5000) {
      tips.add('Ancora qualche passo per raggiungere i 10.000 passi giornalieri');
      tips.add('Prova a utilizzare le scale invece dell\'ascensore');
    } else {
      tips.add('Una camminata di 30 minuti può incrementare significativamente l\'attività');
      tips.add('Considera una passeggiata dopo i pasti principali');
    }
    
    return tips;
  }
}
