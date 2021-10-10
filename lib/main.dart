import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealweek/screens/homescreen.dart';

void main() => runApp(const MealWeek());

class MealWeek extends StatelessWidget {
  const MealWeek({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MealWeek",
      home: const HomeScreen(),
      theme: ThemeData(
        textTheme: GoogleFonts.oswaldTextTheme(),
        primarySwatch: Colors.green,
      ),
    );
  }
}
