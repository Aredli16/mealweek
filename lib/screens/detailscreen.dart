// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mealweek/screens/detailingredientscreen.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détail"),
      ),
      body: SizedBox.expand(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CircleAvatar(
                radius: 90,
                child: Hero(
                  tag: "1", // TODO: Change the tag when implement multiple meal
                  child: Image.asset("assets/icons/lunch.png"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Pate carbonnara".toUpperCase(),
                style: const TextStyle(fontSize: 30),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Card(
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DetailIngredientScreen())),
                      child: ListTile(
                        leading: Hero(
                          tag:
                              "2", //TODO: Change the tag when implement multiple ingredient
                          child: Image.asset(
                            "assets/icons/grocery.png",
                            height: 40,
                          ),
                        ),
                        title: Text("Pate"),
                        subtitle: Text("Quantité: 500g"),
                        trailing: IconButton(
                          onPressed: null,
                          icon: Icon(Icons.more_vert),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
