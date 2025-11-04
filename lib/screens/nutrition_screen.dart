import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walk_and_fit/models/food_item.dart';
import 'package:walk_and_fit/models/daily_nutrition.dart';
import 'package:walk_and_fit/services/database_service.dart';
import 'package:walk_and_fit/services/nutrition_api_service.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _dbService = DatabaseService.instance;
  final _nutritionService = NutritionApiService();
  
  List<FoodItem> _foodItems = [];
  double _caloriesConsumed = 0;
  double _caloriesBurned = 0;
  int _steps = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final foods = await _dbService.getFoodItemsByDate(today);
    final totalCalories = await _dbService.getTotalCaloriesConsumedByDate(today);
    
    final stepRecord = await _dbService.getStepRecordByDate(today);
    final stepsToday = stepRecord?.steps ?? 0;
    final caloriesFromSteps = stepRecord?.calories ?? 0;
    
    setState(() {
      _foodItems = foods;
      _caloriesConsumed = totalCalories;
      _steps = stepsToday;
      _caloriesBurned = caloriesFromSteps;
    });
  }

  DailyNutrition get _dailyNutrition {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return DailyNutrition(
      date: today,
      caloriesConsumed: _caloriesConsumed,
      caloriesBurned: _caloriesBurned,
      steps: _steps.toDouble(),
    );
  }

  void _showAddFoodDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi Cibo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nome cibo',
                hintText: 'es. mela, pasta, pollo',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cerca informazioni nutrizionali online',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              final foodName = controller.text.trim();
              if (foodName.isNotEmpty) {
                Navigator.pop(context);
                await _searchAndAddFood(foodName);
              }
            },
            child: const Text('Cerca'),
          ),
        ],
      ),
    );
  }

  Future<void> _searchAndAddFood(String foodName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final nutritionData = await _nutritionService.getNutritionInfo(foodName);
    
    if (!mounted) return;
    Navigator.pop(context);

    if (nutritionData != null) {
      _showNutritionDetailsDialog(foodName, nutritionData);
    } else {
      _showManualEntryDialog(foodName);
    }
  }

  void _showNutritionDetailsDialog(String foodName, Map<String, dynamic> data) {
    final baseCalories = (data['calories'] ?? 0).toDouble();
    final baseProtein = (data['protein_g'] ?? 0).toDouble();
    final baseCarbs = (data['carbohydrates_total_g'] ?? 0).toDouble();
    final baseFat = (data['fat_total_g'] ?? 0).toDouble();
    final baseServing = (data['serving_size_g'] ?? 100).toDouble();

    final quantityController = TextEditingController(text: baseServing.toInt().toString());
    double currentQuantity = baseServing;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final multiplier = currentQuantity / baseServing;
          final calories = baseCalories * multiplier;
          final protein = baseProtein * multiplier;
          final carbs = baseCarbs * multiplier;
          final fat = baseFat * multiplier;

          return AlertDialog(
            title: Text(foodName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Quantità: '),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          suffixText: 'g',
                          isDense: true,
                        ),
                        onChanged: (value) {
                          final qty = double.tryParse(value);
                          if (qty != null && qty > 0) {
                            setState(() {
                              currentQuantity = qty;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text('Calorie: ${calories.toStringAsFixed(1)} kcal'),
                Text('Proteine: ${protein.toStringAsFixed(1)}g'),
                Text('Carboidrati: ${carbs.toStringAsFixed(1)}g'),
                Text('Grassi: ${fat.toStringAsFixed(1)}g'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () async {
                  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  final food = FoodItem(
                    date: today,
                    name: '$foodName (${currentQuantity.toInt()}g)',
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                    servingSize: currentQuantity,
                    timestamp: DateTime.now().millisecondsSinceEpoch,
                  );
                  
                  await _dbService.insertFoodItem(food);
                  if (context.mounted) Navigator.pop(context);
                  _loadData();
                },
                child: const Text('Aggiungi'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showManualEntryDialog(String foodName) {
    final caloriesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aggiungi $foodName manualmente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dati non trovati. Inserisci manualmente:'),
            const SizedBox(height: 16),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calorie (kcal)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              final calories = double.tryParse(caloriesController.text);
              if (calories != null && calories > 0) {
                final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                final food = FoodItem(
                  date: today,
                  name: foodName,
                  calories: calories,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                );
                
                await _dbService.insertFoodItem(food);
                if (context.mounted) Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = _dailyNutrition;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrizione'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Bilancio Calorico',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCalorieColumn(
                          'Consumate',
                          nutrition.caloriesConsumed,
                          Colors.orange,
                          Icons.restaurant,
                        ),
                        _buildCalorieColumn(
                          'Bruciate',
                          nutrition.totalCaloriesBurned,
                          Colors.green,
                          Icons.local_fire_department,
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: nutrition.isDeficit 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            nutrition.balanceMessage,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: nutrition.isDeficit ? Colors.green : Colors.orange,
                            ),
                          ),
                          if (!nutrition.isDeficit && nutrition.calorieBalance > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Cammina ancora ${nutrition.stepsNeededToBalance.toInt()} passi',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'circa ${nutrition.minutesWalkingNeeded.toInt()} minuti',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cibi Consumati Oggi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Colors.green,
                  onPressed: _showAddFoodDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_foodItems.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('Nessun cibo registrato oggi'),
                  ),
                ),
              )
            else
              ..._foodItems.map((food) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.restaurant, color: Colors.white),
                      ),
                      title: Text(food.name),
                      subtitle: Text(
                        '${food.calories.toStringAsFixed(0)} kcal - ${food.servingSize.toStringAsFixed(0)}g',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _dbService.deleteFoodItem(food.id!);
                          _loadData();
                        },
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieColumn(String label, double value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
