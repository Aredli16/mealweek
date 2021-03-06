import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mealweek/models/ingredient.dart';
import 'package:mealweek/models/meal.dart';
import 'package:mealweek/models/mealhasingredient.dart';
import 'package:mealweek/models/unit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Class which manages the meals database.
///
/// Don't need to initialize it
/// Use the static instance to use it.
///
/// Database is created when you call static instance.
class MealDBHelper {
  /// Define a private default constructor to initialize the static instance of the class
  MealDBHelper._privateDefaultConstructor();

  /// Static instance of MealDBHelper.
  ///
  /// Access all database functionality from this instance.
  /// ```
  ///     MealDBHelper.instance
  /// ```
  static MealDBHelper instance = MealDBHelper._privateDefaultConstructor();

  /// Private instance of the database.
  ///
  /// Never used.
  ///
  /// Used to know if the database exist.
  static Database? _database;

  /// Get the database instance if exist.
  ///
  /// If the database doesn't exist, database is initialized
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database.
  ///
  /// Create database in the android database path
  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, "mealweek.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDB,
      onConfigure: _onConfigureDB,
    );
  }

  /// Create Database
  ///
  /// Initialize the table database with the different relation ship:
  ///
  ///     Meal/Ingredient: ManyToMany
  ///     MealHasIngredient/Unit: OneToMany
  ///
  /// See: sqlite_model_mealweek
  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS meal(
	      mealID INTEGER PRIMARY KEY AUTOINCREMENT,
        mealName VARCHAR(50) UNIQUE NOT NULL
      )
      """);
    await db.execute("""
      CREATE TABLE IF NOT EXISTS meal_random(
        mealID INTEGER,
        mealName VARCHAR(50) UNIQUE NOT NULL
      )
    """); // No primary key for this table because mealID is also a primary key on table meal
    await db.execute("""
      CREATE TABLE IF NOT EXISTS ingredient(
	      ingredientID INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredientName VARCHAR(50) UNIQUE NOT NULL
      )
      """);
    await db.execute("""
      CREATE TABLE IF NOT EXISTS unit(
        unitID INTEGER PRIMARY KEY AUTOINCREMENT,
        unitType VARCHAR(10) UNIQUE NOT NULL
      )
    """);
    await db.execute("""
      CREATE TABLE IF NOT EXISTS meal_has_ingredient(
	      mealID INTEGER NOT NULL,
        ingredientID INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unitID INTEGER NOT NULL,
        PRIMARY KEY(mealID, ingredientID),
        FOREIGN KEY(mealID) REFERENCES meal(mealID) ON DELETE RESTRICT ON UPDATE CASCADE,
        FOREIGN KEY(ingredientID) REFERENCES ingredient(ingredientID) ON DELETE RESTRICT ON UPDATE CASCADE,
        FOREIGN KEY(unitID) REFERENCES unit(unitID) ON DELETE RESTRICT ON UPDATE CASCADE
      )
    """);
  }

  /// Configure the foreign key.
  Future<void> _onConfigureDB(Database database) async {
    await database.execute('PRAGMA foreign_keys = ON');
  }

  /// Inserting default meal
  ///
  /// Assets: assets/data.json
  Future<void> getDefaultMeal() async {
    String data = await rootBundle.loadString("assets/data.json");
    List<dynamic> meals = jsonDecode(data);
    for (var meal in meals) {
      Meal jsonMeal = Meal.fromJson(meal);
      int idJsonMeal = await insertMeal(jsonMeal);
      for (var ing in meal["ingredient"]) {
        Ingredient jsonIng = Ingredient.fromJson(ing);
        int idJsonIng = await insertIngredient(jsonIng);
        Unit jsonUnit = Unit.fromJson(ing);
        int idJsonUnit = await insertUnit(jsonUnit);
        await insertMealHasIngredientManual(
            idJsonMeal, idJsonIng, idJsonUnit, ing["quantity"]);
      }
    }
  }

  /// Insert a [Meal].
  ///
  /// Insert a meal map define in `Meal` class.
  ///
  /// Don't need to specify an [ID]. When meal is mapping, mealID is ignored.
  /// Database give an automatic [ID]
  /// ```
  ///     MealDBHelper.instance.insertMeal(Meal(mealName: "MealName"));
  /// ```
  /// Return `mealID` given by database if no problem.
  ///
  /// If [meal] was on also on database, return the id of existing [meal]
  Future<int> insertMeal(Meal meal) async {
    final Database db = await database;
    try {
      return await db.insert("meal", meal.toMap());
    } catch (e) {
      return getIdMealByName(meal.mealName);
    }
  }

  /// Get all meal of [meal] table. Choose between meal table or meal_random table
  /// ```
  ///     MealDBHelper.instance.getMeals();
  /// ```
  /// Return a [Meal List]
  Future<List<Meal>> getMeals(String table) async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db.query(table);
    return List.generate(
        response.length, (index) => Meal.fromMap(response[index]));
  }

  /// Get a meal where the [ID] is specified
  /// ```
  ///     MealDBHelper.instance.getMealById(1);
  /// ```
  /// Return the firt element where the mealID is equal [ID] parameter
  Future<Meal> getMealById(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> response =
        await db.query("meal", where: "mealID = ?", whereArgs: [id]);
    return Meal.fromMap(response[0]);
  }

  /// Get a meal by his name
  /// ```
  ///     MealDBHelper.instance.getIdMealByName("MealName");
  /// ```
  /// Return the first ID of meal where the name correspond to [name]
  ///
  /// Be careful with case sensitive
  Future<int> getIdMealByName(String name) async {
    final Database db = await database;
    List<Map<String, dynamic>> response =
        await db.query("meal", where: "mealName = ?", whereArgs: [name]);
    Meal mealFound = Meal.fromMap(response[0]);
    return mealFound.mealID;
  }

  /// Insert an [Ingredient].
  ///
  /// Insert an ingredient map define in `Ingredient` class.
  ///
  /// Don't need to specify an [ID]. When ingredient is mapping, ingredientID is ignored.
  /// Database give an automatic [ID]
  /// ```
  ///     MealDBHelper.instance.insertIngredient(Ingredient(ingredientName: "IngredientName"));
  /// ```
  /// Return the `ingredientID` given by database if no problem.
  ///
  /// If [ingredient] was on also on database, return the id of existing [ingredient]
  Future<int> insertIngredient(Ingredient ingredient) async {
    final Database db = await database;
    try {
      return await db.insert("ingredient", ingredient.toMap());
    } catch (e) {
      return getIdIngredientByName(ingredient.ingredientName);
    }
  }

  /// Get all ingredient of ingredient table.
  /// ```
  ///     MealDBHelper.instance.getIngredients();
  /// ```
  /// Return an [Ingredient List]
  Future<List<Ingredient>> getIngredients() async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db.query("ingredient");
    return List.generate(
        response.length, (index) => Ingredient.fromMap(response[index]));
  }

  /// Get an ingredient where the [ID] is specified
  /// ```
  ///     MealDBHelper.instance.getIngredientById(1);
  /// ```
  /// Return the firt element where the ingredientID is equal [ID] parameter
  Future<Ingredient> getIngredientById(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db
        .query("ingredient", where: "ingredientID = ?", whereArgs: [id]);
    return Ingredient.fromMap(response[0]);
  }

  /// Get an ingredient by his name
  /// ```
  ///     MealDBHelper.instance.getIdIngredientByName("IngredientName");
  /// ```
  /// Return the first ID of ingredient where the name correspond to [name]
  ///
  /// Be careful with case sensitive
  Future<int> getIdIngredientByName(String name) async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db
        .query("ingredient", where: "ingredientName = ?", whereArgs: [name]);
    Ingredient ingredientFound = Ingredient.fromMap(response[0]);
    return ingredientFound.ingredientID;
  }

  /// Insert an [Unit].
  ///
  /// Insert an unit map define in `Unit` class.
  ///
  /// Don't need to specify an [ID]. When unit is mapping, unitID is ignored.
  /// Database give an automatic [ID]
  /// ```
  ///     MealDBHelper.instance.insertUnit(Unit(unitType: "g"));
  /// ```
  /// Return the `unitID` given by database if no problem.
  ///
  /// If [unit] was on also on database, return the id of existing [unit]
  Future<int> insertUnit(Unit unit) async {
    final Database db = await database;
    try {
      return await db.insert("unit", unit.toMap());
    } catch (e) {
      return getIdUnitByType(unit.unitType);
    }
  }

  /// Get all unit of unit table.
  /// ```
  ///     MealDBHelper.instance.getIngredients();
  /// ```
  /// Return an [Unit List]
  Future<List<Unit>> getUnit() async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db.query("unit");
    return List.generate(
        response.length, (index) => Unit.fromMap(response[index]));
  }

  /// Get an unit where the [ID] is specified
  /// ```
  ///     MealDBHelper.instance.getUnitById(1);
  /// ```
  /// Return the firt element where the unitID is equal [ID] parameter
  Future<Unit> getUnitById(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> response =
        await db.query("unit", where: "unitID = ?", whereArgs: [id]);
    return Unit.fromMap(response[0]);
  }

  /// Get an unit by his type
  /// ```
  ///     MealDBHelper.instance.getIdUnitByType("IngredientName");
  /// ```
  /// Return the first ID of unit where the type correspond to [type]
  ///
  /// Be careful with case sensitive
  Future<int> getIdUnitByType(String type) async {
    final Database db = await database;
    List<Map<String, dynamic>> response =
        await db.query("unit", where: "unitType = ?", whereArgs: [type]);
    Unit unitFound = Unit.fromMap(response[0]);
    return unitFound.unitID;
  }

  /// Insert the relationship Meal-Ingredient-Unit.
  ///
  /// Before insert, need to verify if the Meal/Ingredient/Unit is on the database.
  /// Check if the `ID = 0`. If `ID = 0`, that corresponds to default ID given by classes.
  ///
  /// ```
  ///     MealDBHelper.instance.inserMealHasIngredient(MealHasIngredient mealHasIngredient);
  /// ```
  ///
  /// After, inserting data into meal_has_ingredient table
  @Deprecated("Long to write")
  Future<int> insertMealHasIngredient(
      MealHasIngredient mealHasIngredient) async {
    if (mealHasIngredient.meal.mealID == 0 &&
        mealHasIngredient.ingredient.ingredientID == 0 &&
        mealHasIngredient.unit.unitID == 0) return -1;
    final Database db = await database;
    try {
      return await db.insert("meal_has_ingredient", mealHasIngredient.toMap());
    } catch (e) {
      return -1;
    }
  }

  /// Insert the relationship Meal-Ingredient-Unit.
  ///
  /// Before insert, need to verify if the Meal/Ingredient/Unit is on the database.
  /// Check if the `ID = 0`. If `ID = 0`, that corresponds to default ID given by classes.
  ///
  ///```
  ///     MealDBHelper.instance.inserMealHasIngredientManual(1, 1, 1, 500);
  /// ```
  ///
  /// After create a manual new MealHasIngredient Object with different [ID]
  ///
  /// The name are ignored because in the relationship table, we just have [ID]
  Future<int> insertMealHasIngredientManual(
      int mealID, int ingredientID, int unitID, int quantity) async {
    if (mealID == 0 && ingredientID == 0 && unitID == 0) return -1;
    final Database db = await database;
    MealHasIngredient mealHasIngredient = MealHasIngredient(
        meal: Meal(mealID: mealID, mealName: "null"),
        ingredient:
            Ingredient(ingredientID: ingredientID, ingredientName: "null"),
        quantity: quantity,
        unit: Unit(unitID: unitID, unitType: "null"));
    try {
      return await db.insert("meal_has_ingredient", mealHasIngredient.toMap());
    } catch (e) {
      return -1;
    }
  }

  /// Delete the relation ship where [mealID] are the same in the table
  /// ```
  ///     MealDBHelper.instance.deleteMealHasIngredientWithMealId(mealID);
  /// ```
  ///
  /// This method delete the meal name too
  ///
  /// Need to delete meal in random_meal too
  Future<void> deleteMealHasIngredientWithMealId(int mealId) async {
    final Database db = await database;
    await db.delete("meal_has_ingredient",
        where: "mealID = ?", whereArgs: [mealId]);
    await db.delete("meal", where: "mealID = ?", whereArgs: [mealId]);
    await db.delete("meal_random", where: "mealID = ?", whereArgs: [mealId]);
  }

  /// Get the realationship Meal-Ingredient-Unit
  ///
  /// Database will check where [mealID] is equal [mealID] and return one
  /// line with all informations about the relationship.
  ///
  /// Return a `MealHasIngredient` because the relationship can have multiple Ingredient.
  ///
  /// Exemple of Map:
  ///
  ///     [{"mealID": 1, "mealName": "MealName1", "ingredientID" : 1, "ingredientName" : "IngredientName1", "quantity": 500, "unitID": 1, "unitType": "g"},
  ///     {"mealID": 1, "mealName": "MealName1", "ingredientID" : 2, "ingredientName" : "IngredientName2", "quantity": 1000, "unitID": 1, "unitType": "g"}]
  ///
  /// MealHasIngredient class can convert this map into several object Meal-Ingredient-Unit
  Future<List<MealHasIngredient>> getMealHasIngredientWithMealId(
      int mealID) async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db.rawQuery("""
      SELECT 
	      *
      FROM 
        meal_has_ingredient
	      JOIN meal USING(mealID) 
        JOIN ingredient USING(ingredientID)
        JOIN unit USING(unitID)
      WHERE 
	      meal.mealID = ? 
    """, [mealID]);
    return List.generate(
        response.length, (index) => MealHasIngredient.fromMap(response[index]));
  }

  /// Return 1 random meal from the table meal
  ///
  /// ```
  ///   MealDBHelper.instance.getRandomMeal();
  /// ```
  Future<Meal> getRandomMeal() async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db.query(
      "meal",
      orderBy: "RANDOM()",
      limit: 1,
    );
    return Meal.fromMap(response[0]);
  }

  /// Insert the random meal list generated
  ///
  /// ```
  ///     MealDBHelper.instance.insertRandomMeals(mealsRandom);
  /// ```
  Future<void> insertRandomMeals(List<Meal> randomMeals) async {
    final Database db = await database;
    db.delete("meal_random");
    for (var meal in randomMeals) {
      db.insert(
          "meal_random", {"mealID": meal.mealID, "mealName": meal.mealName});
    }
  }
}
