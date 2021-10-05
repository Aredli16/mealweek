// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mealweek/screens/detailscreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MealWeek"),
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DetailScreen())),
              child: ListTile(
                title: Text("Pate carbonnara".toUpperCase()),
                leading: Hero(
                  tag: "1", // TODO: Change the tag when implement multiple meal
                  child: Image.asset(
                    "assets/icons/lunch.png",
                    height: 30,
                  ),
                ),
                trailing: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.more_vert),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
