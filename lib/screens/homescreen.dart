import 'package:flutter/material.dart';
import 'package:mealweek/screens/generatescreen.dart';
import 'package:mealweek/screens/listscreen.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedItem = 0;
  List<Widget> screens = [
    const ListScreen(),
    const GenerateScreen(),
  ];

  void _itemSelected(int i) {
    setState(() {
      _selectedItem = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens.elementAt(_selectedItem),
      bottomNavigationBar: WaterDropNavBar(
        waterDropColor: Colors.green,
        inactiveIconColor: Colors.green[300],
        bottomPadding: 10,
        barItems: [
          BarItem(
            filledIcon: Icons.view_list_outlined,
            outlinedIcon: Icons.view_list,
          ),
          BarItem(
            filledIcon: Icons.replay_circle_filled_rounded,
            outlinedIcon: Icons.replay,
          ),
        ],
        selectedIndex: _selectedItem,
        onItemSelected: _itemSelected,
      ),
    );
  }
}
