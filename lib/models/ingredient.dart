class Ingredient {
  final int ingredientID;
  final String ingredientName;

  Ingredient({
    this.ingredientID = 0,
    required this.ingredientName,
  });

  Map<String, dynamic> toMap() {
    return {
      "ingredientName": ingredientName,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      ingredientID: map["ingredientID"],
      ingredientName: map["ingredientName"],
    );
  }

  @override
  String toString() {
    return "Ingredient(ingredientID: $ingredientID / ingredientName: $ingredientName)";
  }
}
