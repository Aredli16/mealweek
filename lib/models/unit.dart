class Unit {
  final int unitID;
  final String unitType;

  Unit({this.unitID = 0, required this.unitType});

  Map<String, dynamic> toMap() {
    return {
      "unitID": unitID,
      "unitType": unitType,
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(unitID: map["unitID"], unitType: map["unitType"]);
  }

  @override
  String toString() {
    return "Unit(unitID: $unitID / unitType: $unitType)";
  }
}
