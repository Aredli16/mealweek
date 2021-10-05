import 'package:mealweek/models/ingredient.dart';
import 'package:mealweek/models/meal.dart';

class MealHasIngredient {
  final Meal meal;
  final Ingredient ingredient;
  final int quantity;

  MealHasIngredient({
    required this.meal,
    required this.ingredient,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      "mealID": meal.mealID,
      "ingredientID": ingredient.ingredientID,
      "quantity": quantity,
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
    );
  }

  @override
  String toString() {
    return "MealHasIngredient(meal: [$meal] / ingredient: [$ingredient] / quantity: $quantity)";
  }
}
