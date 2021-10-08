import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealweek/databases/mealdbhelper.dart';
import 'package:mealweek/models/ingredient.dart';
import 'package:mealweek/models/meal.dart';
import 'package:mealweek/models/unit.dart';
import 'package:mealweek/screens/homescreen.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<
      FormState>(); // Used to verify the data compliance in the Form Widget
  late String mealName; // String who contains future mealName
  List<NewIngredientField> ingredientField =
      []; // Represent each ingredient field

  @override
  void initState() {
    super.initState();
    ingredientField.add(NewIngredientField(onDelete: _deleteField));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un repas"),
        actions: [
          IconButton(onPressed: _validate, icon: const Icon(Icons.check))
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Nom du repas",
                ),
                textCapitalization: TextCapitalization.sentences,
                autovalidateMode: AutovalidateMode
                    .onUserInteraction, // Delete the error message if the input was not valid
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer le nom du repas"; // If the user didn't type text for mealName
                  }
                  return null;
                },
                onChanged: (value) =>
                    mealName = value, // Get the text of mealName Input
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ingredientField.length +
                      1, // Print each field + 1 button to add a new field
                  itemBuilder: (context, index) {
                    if (index != ingredientField.length) {
                      // Not at the end of the list
                      return ingredientField[index];
                    } else {
                      // At the end of the list so return a button
                      return IconButton(
                        onPressed: _addNewField,
                        icon: const Icon(Icons.add, color: Colors.green),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Callback. When user click on (+) need to add a new field
  ///
  /// You can't add a new field if the last field are empty
  ///
  /// Add new field into ingredientField and `setState()` to reload the screen
  void _addNewField() {
    if (ingredientField.last._ingredientController.text.isEmpty &&
        ingredientField.last._quantityController.text.isEmpty) {
      _formKey.currentState!.validate();
    } else {
      ingredientField.add(NewIngredientField(onDelete: _deleteField));
      setState(() {});
    }
  }

  /// Callback. When the user click on delete button
  ///
  /// Need to delete the good text field in the list and reload the screen
  ///
  /// The button is on the NewIngredientField Class, so need to pass this method
  /// into NewIngredientField Constructor
  void _deleteField(NewIngredientField ingredientFieldDelete) {
    ingredientField.remove(ingredientFieldDelete);
    setState(() {});
  }

  /// When user click on the valid button
  ///
  /// Check if all information are OK
  ///
  /// Insert data if informations are correct
  void _validate() async {
    if (_formKey.currentState!.validate()) {
      // Data are correct
      Meal meal = Meal(
          mealName: removeDiacritics(mealName
              .trim())); // Trim remove inutile begin or end spaces // removeDiacritics remove all accent
      int mealID = await MealDBHelper.instance
          .insertMeal(meal); // Insert MEAL into database

      for (var ingredientField in ingredientField) {
        // Route of each ingredient field
        Ingredient ingredient = Ingredient(
            ingredientName: removeDiacritics(ingredientField
                ._ingredientController.text
                .trim())); // Retrieve text thanks to controller
        Unit unit = Unit(
            unitType: removeDiacritics(ingredientField._unitController.text
                .trim())); // Retrieve text thanks to controller

        // Insert INGREDIENT + UNIT into database
        int ingredientID =
            await MealDBHelper.instance.insertIngredient(ingredient);
        int unitID = await MealDBHelper.instance.insertUnit(unit);

        // Retrieve quantity and parse to int
        int quantity = int.parse(ingredientField._quantityController.text);

        // Insert the relationship
        await MealDBHelper.instance.insertMealHasIngredientManual(
            mealID, ingredientID, unitID, quantity);
      }
      // When inserted into database: pop and reload
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false);
    }
  }
}

class NewIngredientField extends StatelessWidget {
  NewIngredientField({
    Key? key,
    required this.onDelete,
  }) : super(key: key);

  final TextEditingController _ingredientController =
      TextEditingController(); // Need to get IngredientInput text
  final TextEditingController _quantityController =
      TextEditingController(); // Need to get QuantityInput text
  final TextEditingController _unitController =
      TextEditingController(); // Need to get UnitInput text
  final void Function(NewIngredientField)
      onDelete; // Callback when delete button is press

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(labelText: "Ingredient"),
              textCapitalization: TextCapitalization.sentences,
              autovalidateMode: AutovalidateMode
                  .onUserInteraction, // Delete the error message if the input was not valid
              controller:
                  _ingredientController, // Pass the text into the controller
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez indiquer l'ingrédient";
                }
                return null;
              },
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(labelText: "Quantité"),
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autovalidateMode: AutovalidateMode
                  .onUserInteraction, // Delete the error message if the input was not valid
              controller:
                  _quantityController, // Pass the text into the controller
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez indiquer la quantité";
                }
                return null;
              },
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(labelText: "Unité"),
              autovalidateMode: AutovalidateMode
                  .onUserInteraction, // Delete the error message if the input was not valid
              controller: _unitController, // Pass the text into the controller
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez indiquer l'unité";
                }
                return null;
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: _delete,
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        )
      ],
    );
  }

  /// Callback. When the user press delete icon, this method call the callback
  /// _deleteField into AddScreen Class
  ///
  /// Delete the field
  void _delete() {
    onDelete(this); // Delete "this" Field
  }
}
