// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mealweek/databases/mealdbhelper.dart';
import 'package:mealweek/models/meal.dart';
import 'package:mealweek/models/mealhasingredient.dart';
import 'package:mealweek/screens/detailingredientscreen.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key, required this.meal}) : super(key: key);

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détail: " + meal.mealName),
      ),
      body: SizedBox.expand(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CircleAvatar(
                radius: 90,
                child: Hero(
                  tag: meal,
                  child: Image.asset("assets/icons/lunch.png"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                meal.mealName.toUpperCase(),
                style: const TextStyle(fontSize: 30),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<MealHasIngredient>>(
                  future: MealDBHelper.instance
                      .getMealHasIngredientWithMealId(meal.mealID),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: InkWell(
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DetailIngredientScreen(
                                              mealHasIngredient:
                                                  snapshot.data![index]))),
                              child: ListTile(
                                leading: Hero(
                                  tag: snapshot.data![index],
                                  child: Image.asset(
                                    "assets/icons/grocery.png",
                                    height: 40,
                                  ),
                                ),
                                title: Text(snapshot
                                    .data![index].ingredient.ingredientName),
                                subtitle: Text("Quantité: " +
                                    snapshot.data![index].quantity.toString()),
                                trailing: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.more_vert),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
