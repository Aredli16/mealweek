import 'package:flutter/material.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un repas"),
        actions: const [IconButton(onPressed: null, icon: Icon(Icons.check))],
      ),
    );
  }
}
