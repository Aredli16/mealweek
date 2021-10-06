import 'package:mealweek/models/ingredient.dart';
import 'package:mealweek/models/meal.dart';
import 'package:mealweek/models/unit.dart';

/// MealHasIngredient Model
class MealHasIngredient {
  final Meal meal;
  final Ingredient ingredient;
  final int quantity;
  final Unit unit;

  /// Constructor for MealHasIngredient Class
  MealHasIngredient({
    required this.meal,
    required this.ingredient,
    required this.quantity,
    required this.unit,
  });

  /// Convert the object instance to map
  ///
  /// We just need to map the differents [ID] on Many-to-Many relationship
  ///
  Map<String, dynamic> toMap() {
    return {
      "mealID": meal.mealID,
      "ingredientID": ingredient.ingredientID,
      "quantity": quantity,
      "unitID": unit.unitID,
    };
  }

  /// Convert MealHasIngredient Map to MealHasIngredient Object
  ///
  /// See the map format on MealDBHelper. Each information of each object are
  /// given in this map. So we can instantiate the different object
  factory MealHasIngredient.fromMap(Map<String, dynamic> map) {
    return MealHasIngredient(
      meal: Meal(
        mealID: map["mealID"],
        mealName: map["mealName"],
      ),
      ingredient: Ingredient(
        ingredientID: map["ingredientID"],
        ingredientName: map["ingredientName"],
      ),
      quantity: map["quantity"],
      unit: Unit(
        unitID: map["unitID"],
        unitType: map["unitType"],
      ),
    );
  }

  @override
  String toString() {
    return "MealHasIngredient(meal: [$meal] / ingredient: [$ingredient] / quantity: $quantity / unit: [$unit])";
  }
}
