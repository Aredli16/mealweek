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
  /// If problem return `-1`
  Future<int> insertMeal(Meal meal) async {
    final Database db = await database;
    try {
      return await db.insert("meal", meal.toMap());
    } catch (e) {
      return -1;
    }
  }

  /// Get all meal of meal table.
  /// ```
  ///     MealDBHelper.instance.getMeals();
  /// ```
  /// Return a [Meal List]
  Future<List<Meal>> getMeals() async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db.query("meal");
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
  /// If problem return `-1`
  Future<int> insertIngredient(Ingredient ingredient) async {
    final Database db = await database;
    try {
      return await db.insert("ingredient", ingredient.toMap());
    } catch (e) {
      return -1;
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
  /// If problem return `-1`
  Future<int> insertUnit(Unit unit) async {
    final Database db = await database;
    try {
      return await db.insert("unit", unit.toMap());
    } catch (e) {
      return -1;
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

  /// Insert the relationship Meal-Ingredient-Unit.
  ///
  /// Before insert, need to verify if the Meal/Ingredient/Unit is on the database.
  /// Check if the `ID = 0`. If `ID = 0`, that corresponds to default ID given by classes.
  ///
  /// After, inserting data into meal_has_ingredient table
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
	      meal, 
        ingredient, 
        meal_has_ingredient,
        unit
      WHERE 
	      meal.mealID = ? 
        AND meal.mealID = meal_has_ingredient.mealID 
        AND ingredient.ingredientID = meal_has_ingredient.ingredientID
        AND unit.unitID = meal_has_ingredient.unitID
    """, [mealID]);
    return List.generate(
        response.length, (index) => MealHasIngredient.fromMap(response[index]));
  }
}
