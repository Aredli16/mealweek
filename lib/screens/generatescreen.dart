import 'package:flutter/material.dart';
import 'package:mealweek/databases/mealdbhelper.dart';
import 'package:mealweek/models/meal.dart';
import 'package:mealweek/screens/detailscreen.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({Key? key}) : super(key: key);

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  List<Meal> futureMealList = [];
  final List<String> days = [
    "Lundi",
    "Mardi",
    "Mercredi",
    "Jeudi",
    "Vendredi",
    "Samedi",
    "Dimanche"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _getInitGeneratedMeal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Générer un menu aléatoire"),
        actions: [
          IconButton(
              onPressed: _generateMealList, icon: const Icon(Icons.replay)),
        ],
      ),
      body: futureMealList.isEmpty || futureMealList.length < 7
          ? Center(
              child: TextButton(
                onPressed: _generateMealList,
                child: Text("Cliquez ici pour générer un menu".toUpperCase()),
              ),
            )
          : ListView.builder(
              itemCount: futureMealList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: buildDay(index),
                    ),
                    buildRandomMeal(index),
                  ],
                );
              },
            ),
    );
  }

  Text buildDay(int index) {
    return Text(
      days[index].toUpperCase(),
      style: const TextStyle(fontSize: 19),
    );
  }

  Card buildRandomMeal(int index) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DetailScreen(meal: futureMealList[index]),
        )),
        child: ListTile(
          leading: Hero(
            tag: futureMealList[index],
            child: Image.asset(
              "assets/icons/lunch.png",
              height: 40,
            ),
          ),
          title: Text(futureMealList[index].mealName.toUpperCase()),
          trailing: IconButton(
            onPressed: () => _refreshOneMeal(index),
            icon: const Icon(Icons.refresh),
          ),
        ),
      ),
    );
  }

  /// Generate a random mealList
  ///
  /// MealList mustn't to have same meal
  ///
  /// MealList must have 7 meal (for 7 days)
  void _generateMealList() async {
    List<Meal> mealList = await MealDBHelper.instance.getMeals("meal");
    if (mealList.length < 7) {
      // If mealList is not < 7, we can't create a menu
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Il vous faut plus de repas dans votre liste".toUpperCase()),
      ));
      return;
    }
    List<Meal> generatingMealList = [];
    while (generatingMealList.length < 7) {
      Meal randomMeal = await MealDBHelper.instance.getRandomMeal();
      while (!generatingMealList.contains(randomMeal)) {
        // Can't have the same meal in 1 week
        generatingMealList.add(randomMeal);
      }
    }
    setState(() {
      futureMealList = generatingMealList;
    });
    await MealDBHelper.instance.insertRandomMeals(futureMealList);
  }

  /// This method use to resfresh one meal in the list
  ///
  /// It verify also if the meal isn't on the current list
  void _refreshOneMeal(int index) async {
    Meal refreshedMeal;
    do {
      refreshedMeal = await MealDBHelper.instance.getRandomMeal();
    } while (futureMealList.contains(refreshedMeal));
    futureMealList[index] = refreshedMeal;
    MealDBHelper.instance.insertRandomMeals(
        futureMealList); // Update the random meal list in database
    setState(() {});
  }

  /// Method who get init random meal
  void _getInitGeneratedMeal() async {
    List<Meal> initGeneratedMeal =
        await MealDBHelper.instance.getMeals("meal_random");
    setState(() {
      futureMealList = initGeneratedMeal;
    });
  }
}
