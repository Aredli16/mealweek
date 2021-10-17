/// Unit model
class Unit {
  /// An unique [unitID] in the database
  final int unitID;

  /// And unique [unitType] in the database
  final String unitType;

  /// Constructor for Unit Class
  ///
  /// [unitID] is optional because the database can give an unique [unitID]
  ///
  /// [unitType] can be unique, if not unique, database will ignore it
  Unit({this.unitID = 0, required this.unitType});

  /// Convert the object instance to map
  ///
  /// Just [unitType] is mapped because [unitID] is given by database
  Map<String, dynamic> toMap() {
    return {
      "unitType": unitType,
    };
  }

  /// Constructor for Unit Class
  ///
  /// Return a `Unit` from Map.
  ///
  /// [unitID] is specified because it's returned by database
  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      unitID: map["unitID"],
      unitType: map["unitType"],
    );
  }

  /// Constructor for Unit Class
  ///
  /// Return a `Unit` from a json file.
  ///
  /// [unitID] is not specified because database will return an id
  factory Unit.fromJson(Map<String, dynamic> map) {
    return Unit(
      unitType: map["unit"],
    );
  }

  @override
  String toString() {
    return "Unit(unitID: $unitID / unitType: $unitType)";
  }
}
