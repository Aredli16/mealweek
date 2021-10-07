import 'package:flutter/material.dart';
import 'package:mealweek/databases/mealdbhelper.dart';
import 'package:mealweek/models/meal.dart';
import 'package:mealweek/screens/add_screen.dart';
import 'package:mealweek/screens/detailscreen.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste de mes repas"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const DatabaseList(),
                ));
              },
              icon: const Icon(Icons.code))
        ],
      ),
      body: FutureBuilder<List<Meal>>(
          future:
              MealDBHelper.instance.getMeals(), // Get all Meals from database
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(meal: snapshot.data![index]))),
                      child: ListTile(
                        title:
                            Text(snapshot.data![index].mealName.toUpperCase()),
                        leading: Hero(
                          tag: snapshot.data![index],
                          child: Image.asset(
                            "assets/icons/lunch.png",
                            height: 30,
                          ),
                        ),
                        trailing: const IconButton(
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
              return const Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AddScreen())),
      ),
    );
  }
}
