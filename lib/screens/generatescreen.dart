import 'package:flutter/material.dart';

class GenerateScreen extends StatelessWidget {
  const GenerateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Générer un menu aléatoire"),
      ),
    );
  }
}
