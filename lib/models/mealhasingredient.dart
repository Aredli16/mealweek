import 'package:mealweek/models/ingredient.dart';
import 'package:mealweek/models/meal.dart';
import 'package:mealweek/models/unit.dart';

class MealHasIngredient {
  final Meal meal;
  final Ingredient ingredient;
  final int quantity;
  final Unit unit;

  MealHasIngredient({
    required this.meal,
    required this.ingredient,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      "mealID": meal.mealID,
      "ingredientID": ingredient.ingredientID,
      "quantity": quantity,
      "unitID": unit.unitID,
    };
  }

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
