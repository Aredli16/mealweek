import 'package:flutter/material.dart';
import 'package:mealweek/databases/mealdbhelper.dart';
import 'package:mealweek/models/meal.dart';
import 'package:mealweek/screens/add_screen.dart';
import 'package:mealweek/screens/detailscreen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<Meal>> futureListMeal;

  @override
  void initState() {
    super.initState();
    futureListMeal = updateAndGetList();
  }

  Future<List<Meal>> updateAndGetList() async {
    List<Meal> mealList =
        await MealDBHelper.instance.getMeals("meal"); // Fetching data
    if (mealList.isEmpty) {
      // No data => new database
      await MealDBHelper.instance.getDefaultMeal(); // Add default data
    }
    return MealDBHelper.instance.getMeals("meal"); // Refetching data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste de mes repas"),
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.of(context).push(MaterialPageRoute(
        //           builder: (context) => const DatabaseList(),
        //         ));
        //       },
        //       icon: const Icon(Icons.code))
        // ],
      ),
      body: FutureBuilder<List<Meal>>(
          future: futureListMeal,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(snapshot.data![index].toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        _deleteMeal(
                          Meal(
                            mealID: snapshot.data![index].mealID,
                            mealName: snapshot.data![index].mealName,
                          ),
                        );
                        snapshot.data!.removeAt(index);
                        setState(() {});
                      }
                    },
                    background: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Icon(Icons.delete),
                      ),
                    ),
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    DetailScreen(meal: snapshot.data![index]))),
                        child: ListTile(
                            title: Text(
                                snapshot.data![index].mealName.toUpperCase()),
                            leading: Hero(
                              tag: snapshot.data![index],
                              child: Image.asset(
                                "assets/icons/lunch.png",
                                height: 40,
                              ),
                            ),
                            trailing: PopupMenuButton(
                              iconSize: 50,
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    onTap: () async {
                                      _deleteMeal(
                                        Meal(
                                          mealID: snapshot.data![index].mealID,
                                          mealName:
                                              snapshot.data![index].mealName,
                                        ),
                                      );
                                      snapshot.data!.removeAt(index);
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Supprimer".toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ];
                              },
                              child: const Icon(Icons.more_vert),
                            )),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text("R??cup??ration de vos recettes..."),
                    ),
                  ],
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AddScreen())),
      ),
    );
  }

  /// Delete the meal in the database
  ///
  /// Show snackbar confirmation
  void _deleteMeal(Meal meal) async {
    await MealDBHelper.instance.deleteMealHasIngredientWithMealId(meal.mealID);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("[" + meal.mealName + "]" + " a ??t?? supprim??"),
      ),
    );
  }
}
