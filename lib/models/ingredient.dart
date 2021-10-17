/// Ingredient Model
class Ingredient {
  /// An unique [ingredientID] in the database
  final int ingredientID;

  /// An unique [name] in the database
  final String ingredientName;

  /// Constructor for Ingredient Class
  ///
  /// [ingredientID] is optional because the database can give an unique [ingredientID]
  ///
  /// [ingredientName] can be unique, if not unique, database will ignore it
  Ingredient({
    this.ingredientID = 0,
    required this.ingredientName,
  });

  /// Convert the object instance to map
  ///
  /// Just [ingredientName] is mapped because [ingredientID] is given by database
  Map<String, dynamic> toMap() {
    return {
      "ingredientName": ingredientName,
    };
  }

  /// Constructor for Ingredient Class
  ///
  /// Return a `Ingredient` from Map.
  ///
  /// [ingredientID] is specified because it's returned by database
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      ingredientID: map["ingredientID"],
      ingredientName: map["ingredientName"],
    );
  }

  /// Constructor for Ingredient Class
  ///
  /// Return a `Ingredient` from a json file.
  ///
  /// [ingredientID] is not specified because database will return an id
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientName: json["ingredientName"],
    );
  }

  @override
  String toString() {
    return "Ingredient(ingredientID: $ingredientID / ingredientName: $ingredientName)";
  }
}
