import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';
import 'dart:io';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food_app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final String path = join(documentsDir.path, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE order_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        target_cost REAL NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE plan_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER NOT NULL,
        food_id INTEGER NOT NULL,
        FOREIGN KEY (plan_id) REFERENCES order_plans (id) ON DELETE CASCADE,
        FOREIGN KEY (food_id) REFERENCES food_items (id)
      );
    ''');

    // Insert initial ~20 food items
    await _insertInitialFoodItems(db);
  }

  Future<void> _insertInitialFoodItems(Database db) async {
    final items = [
      {'name': 'Burger', 'price': 8.99},
      {'name': 'Pizza Slice', 'price': 4.50},
      {'name': 'Pasta', 'price': 10.00},
      {'name': 'Salad', 'price': 6.00},
      {'name': 'Sandwich', 'price': 5.50},
      {'name': 'Sushi Roll', 'price': 9.00},
      {'name': 'Chicken Wrap', 'price': 7.50},
      {'name': 'Fries', 'price': 3.00},
      {'name': 'Taco', 'price': 3.50},
      {'name': 'Steak', 'price': 15.00},
      {'name': 'Smoothie', 'price': 4.75},
      {'name': 'Coffee', 'price': 2.50},
      {'name': 'Tea', 'price': 2.00},
      {'name': 'Muffin', 'price': 2.75},
      {'name': 'Bagel', 'price': 2.25},
      {'name': 'Soup', 'price': 4.25},
      {'name': 'Noodles', 'price': 8.00},
      {'name': 'Rice Bowl', 'price': 7.25},
      {'name': 'Ice Cream', 'price': 3.75},
      {'name': 'Juice', 'price': 3.25},
    ];

    for (final item in items) {
      await db.insert('food_items', item);
    }
  }

  // CRUD for FoodItem
  Future<List<FoodItem>> getAllFoodItems() async {
    final db = await database;
    final result = await db.query('food_items', orderBy: 'name ASC');
    return result.map((e) => FoodItem.fromMap(e)).toList();
  }

  Future<int> insertFoodItem(FoodItem item) async {
    final db = await database;
    return db.insert('food_items', item.toMap());
  }

  Future<int> updateFoodItem(FoodItem item) async {
    final db = await database;
    return db.update(
      'food_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteFoodItem(int id) async {
    final db = await database;
    return db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }

  // Save or update order plan for a date
  Future<void> saveOrderPlan({
    required String date,
    required double targetCost,
    required List<int> selectedFoodIds,
  }) async {
    final db = await database;

    // Check if plan already exists for that date
    final existing = await db.query(
      'order_plans',
      where: 'date = ?',
      whereArgs: [date],
    );

    int planId;
    if (existing.isEmpty) {
      planId = await db.insert('order_plans', {
        'date': date,
        'target_cost': targetCost,
      });
    } else {
      planId = existing.first['id'] as int;
      await db.update(
        'order_plans',
        {'target_cost': targetCost},
        where: 'id = ?',
        whereArgs: [planId],
      );

      // delete old plan_items
      await db.delete('plan_items', where: 'plan_id = ?', whereArgs: [planId]);
    }

    // insert new plan_items
    for (final foodId in selectedFoodIds) {
      await db.insert('plan_items', {
        'plan_id': planId,
        'food_id': foodId,
      });
    }
  }

  // Get plan for a given date
  Future<Map<String, dynamic>?> getOrderPlanByDate(String date) async {
    final db = await database;

    final plans = await db.query(
      'order_plans',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (plans.isEmpty) return null;

    final plan = OrderPlan.fromMap(plans.first);

    final items = await db.rawQuery('''
      SELECT food_items.*
      FROM plan_items
      JOIN food_items ON food_items.id = plan_items.food_id
      WHERE plan_items.plan_id = ?
    ''', [plan.id]);

    final foodItems = items.map((e) => FoodItem.fromMap(e)).toList();

    return {
      'plan': plan,
      'foods': foodItems,
    };
  }
}
