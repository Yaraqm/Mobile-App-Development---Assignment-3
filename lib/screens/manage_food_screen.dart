// manage_food_screen.dart
// CRUD screen for food_items with pastel cards.

import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/food_item.dart';

class ManageFoodScreen extends StatefulWidget {
  static const routeName = '/manage-food';

  const ManageFoodScreen({super.key});

  @override
  State<ManageFoodScreen> createState() => _ManageFoodScreenState();
}

class _ManageFoodScreenState extends State<ManageFoodScreen> {
  List<FoodItem> _foodItems = [];

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await AppDatabase.instance.getAllFoodItems();
    setState(() => _foodItems = items);
  }

  Future<void> _showFoodDialog({FoodItem? existing}) async {
    final nameController =
    TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(
      text: existing?.price.toStringAsFixed(2) ?? '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(existing == null ? 'Add food item' : 'Edit food item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.fastfood),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text);

    if (name.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid name or price')),
      );
      return;
    }

    if (existing == null) {
      await AppDatabase.instance.insertFoodItem(
        FoodItem(name: name, price: price),
      );
    } else {
      await AppDatabase.instance.updateFoodItem(
        FoodItem(id: existing.id, name: name, price: price),
      );
    }

    await _loadFoodItems();
  }

  Future<void> _deleteItem(FoodItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text('Delete item'),
        content: Text('Delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AppDatabase.instance.deleteFoodItem(item.id!);
      await _loadFoodItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage food items'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF6F0FF),
              Color(0xFFECE3FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              itemCount: _foodItems.length,
              itemBuilder: (context, index) {
                final item = _foodItems[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.fastfood),
                    title: Text(item.name),
                    subtitle:
                    Text('\$${item.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showFoodDialog(existing: item),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteItem(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFoodDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
    );
  }
}
