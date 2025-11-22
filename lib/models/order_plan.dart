class OrderPlan {
  final int? id;
  final String date; // store as "yyyy-MM-dd"
  final double targetCost;

  OrderPlan({this.id, required this.date, required this.targetCost});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'target_cost': targetCost,
    };
  }

  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    return OrderPlan(
      id: map['id'] as int?,
      date: map['date'] as String,
      targetCost: (map['target_cost'] as num).toDouble(),
    );
  }
}
