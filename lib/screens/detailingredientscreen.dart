import 'package:flutter/material.dart';

class DetailIngredientScreen extends StatelessWidget {
  const DetailIngredientScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail"),
      ),
      body: SizedBox.expand(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Hero(
                tag: "2", //TODO: Change tag when implement multiple ingredient
                child: CircleAvatar(
                  radius: 90,
                  child: Image.asset("assets/icons/grocery.png"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Pate".toUpperCase(),
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
