// Model class representing a daily order plan entry
class OrderPlan {
  final int? id;
  final String date; // store as "yyyy-MM-dd"
  final double targetCost;

  // Constructor with optional id (auto-generated in DB)
  OrderPlan({this.id, required this.date, required this.targetCost});

  // Convert OrderPlan object into a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'target_cost': targetCost,
    };
  }

  // Factory method to create an OrderPlan object from a Map
  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    return OrderPlan(
      id: map['id'] as int?,
      date: map['date'] as String,
      targetCost: (map['target_cost'] as num).toDouble(),
    );
  }
}
