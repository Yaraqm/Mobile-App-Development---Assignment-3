// Model class representing a single food item entity
class FoodItem {
  final int? id;
  final String name;
  final double price;

  // Constructor with optional id (auto-incremented in DB)
  FoodItem({this.id, required this.name, required this.price});

  // Convert FoodItem object into a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  // Factory method to create a FoodItem object from a Map
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
    );
  }
}
