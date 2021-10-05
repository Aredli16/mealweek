class Meal {
  final int mealID;
  final String mealName;

  Meal({
    this.mealID = 0,
    required this.mealName,
  });

  Map<String, dynamic> toMap() {
    return {
      "mealName": mealName,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      mealID: map["mealID"],
      mealName: map["mealName"],
    );
  }
  @override
  String toString() {
    return "Meal(mealID: $mealID / mealName: $mealName)";
  }
}
