import 'package:flutter/material.dart';
import 'package:mealweek/models/mealhasingredient.dart';

class DetailIngredientScreen extends StatelessWidget {
  const DetailIngredientScreen({Key? key, required this.mealHasIngredient})
      : super(key: key);

  final MealHasIngredient
      mealHasIngredient; // Relation is recovered thanks to DetailIngredientScreen class

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail: " + mealHasIngredient.ingredient.ingredientName),
      ),
      body: SizedBox.expand(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Hero(
                tag: mealHasIngredient,
                child: CircleAvatar(
                  radius: 90,
                  child: Image.asset("assets/icons/grocery.png"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                mealHasIngredient.ingredient.ingredientName.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
