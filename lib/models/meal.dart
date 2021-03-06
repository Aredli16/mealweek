/// Meal Model
class Meal {
  /// An unique [mealID] in the database
  final int mealID;

  /// And unique [mealName] in the database
  final String mealName;

  /// Constructor for Meal Class
  ///
  /// [mealID] is optional because the database can give an unique [mealID]
  ///
  /// [mealName] can be unique, if not unique, database will ignore it
  Meal({
    this.mealID = 0,
    required this.mealName,
  });

  /// Convert the object instance to map
  ///
  /// Just [mealName] is mapped because [mealID] is given by database
  Map<String, dynamic> toMap() {
    return {
      "mealName": mealName,
    };
  }

  /// Constructor for Meal Class
  ///
  /// Return a `Meal` from Map.
  ///
  /// [mealID] is specified because it's returned by database
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      mealID: map["mealID"],
      mealName: map["mealName"],
    );
  }

  /// Constructor for Meal Class
  ///
  /// Return a `Meal`from a json file
  ///
  /// [mealId] is not specified because database will give an id
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      mealName: json["mealName"],
    );
  }

  @override
  String toString() {
    return "Meal(mealID: $mealID / mealName: $mealName)";
  }

  @override
  bool operator ==(Object other) => other is Meal && mealID == other.mealID;

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}
