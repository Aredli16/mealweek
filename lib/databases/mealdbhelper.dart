import 'package:mealweek/models/ingredient.dart';
import 'package:mealweek/models/meal.dart';
import 'package:mealweek/models/mealhasingredient.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MealDBHelper {
  MealDBHelper._privateDefaultConstructor();
  static MealDBHelper instance = MealDBHelper._privateDefaultConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

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

  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS meal(
	    mealID INTEGER PRIMARY KEY AUTOINCREMENT,
      mealName VARCHAR(50) UNIQUE NOT NULL
      );
      """);
    await db.execute("""
      CREATE TABLE IF NOT EXISTS ingredient(
	    ingredientID INTEGER PRIMARY KEY AUTOINCREMENT,
      ingredientName VARCHAR(50) UNIQUE NOT NULL
      );
      """);
    await db.execute("""
      CREATE TABLE IF NOT EXISTS meal_has_ingredient(
	    mealID INTEGER NOT NULL,
      ingredientID INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      PRIMARY KEY(mealID, ingredientID),
      FOREIGN KEY(mealID) REFERENCES meal(mealID) ON DELETE RESTRICT ON UPDATE CASCADE,
      FOREIGN KEY(ingredientID) REFERENCES ingredient(ingredientID) ON DELETE RESTRICT ON UPDATE CASCADE
      );
    """);
  }

  Future<void> _onConfigureDB(Database database) async {
    await database.execute('PRAGMA foreign_keys = ON');
  }

  Future<int> insertMeal(Meal meal) async {
    final Database db = await database;
    try {
      return await db.insert("meal", meal.toMap());
    } catch (e) {
      return -1;
    }
  }

  Future<List<Meal>> getMeals() async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db.query("meal");
    return List.generate(
        response.length, (index) => Meal.fromMap(response[index]));
  }

  Future<Meal> getMealById(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> response =
        await db.query("meal", where: "mealID = ?", whereArgs: [id]);
    return Meal.fromMap(response[0]);
  }

  Future<int> insertIngredient(Ingredient ingredient) async {
    final Database db = await database;
    try {
      return await db.insert("ingredient", ingredient.toMap());
    } catch (e) {
      return -1;
    }
  }

  Future<List<Ingredient>> getIngredients() async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db.query("ingredient");
    return List.generate(
        response.length, (index) => Ingredient.fromMap(response[index]));
  }

  Future<Ingredient> getIngredientById(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db
        .query("ingredient", where: "ingredientID = ?", whereArgs: [id]);
    return Ingredient.fromMap(response[0]);
  }

  Future<int> insertMealHasIngredient(
      MealHasIngredient mealHasIngredient) async {
    if (mealHasIngredient.meal.mealID == 0 &&
        mealHasIngredient.ingredient.ingredientID == 0) return -1;
    final Database db = await database;
    try {
      return await db.insert("meal_has_ingredient", mealHasIngredient.toMap());
    } catch (e) {
      return -1;
    }
  }

  Future<List<MealHasIngredient>> getMealHasIngredientWithMealId(
      int mealID) async {
    final Database db = await database;
    List<Map<String, dynamic>> response = await db.rawQuery("""
      SELECT 
	      *
      FROM 
	      meal, 
        ingredient, 
        meal_has_ingredient
      WHERE 
	      meal.mealID = ? 
        AND meal.mealID = meal_has_ingredient.mealID 
        AND ingredient.ingredientID = meal_has_ingredient.ingredientID;

    """, [mealID]);
    return List.generate(
        response.length, (index) => MealHasIngredient.fromMap(response[index]));
  }
}
