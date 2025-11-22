// home_screen.dart
// Main planning screen – pastel UI + separate budget vs food editing.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/app_database.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';
import 'manage_food_screen.dart';
import 'view_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _targetCost = 0.0;
  DateTime _selectedDate = DateTime.now();
  List<FoodItem> _foodItems = [];
  Set<int> _selectedFoodIds = {};
  double _currentTotal = 0.0;

  bool _isEditing = true; // controls whether food items are editable

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);
  double get _remaining =>
      (_targetCost - _currentTotal).clamp(0, double.infinity);

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
    _loadExistingPlanForDate();
  }

  // Load all available food items from database
  Future<void> _loadFoodItems() async {
    final items = await AppDatabase.instance.getAllFoodItems();
    setState(() => _foodItems = items);
  }

  // Show a date picker to select plan date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadExistingPlanForDate();
    }
  }

  // Dialog for entering daily budget/target cost
  Future<void> _showBudgetDialog() async {
    final controller =
    TextEditingController(text: _targetCost.toStringAsFixed(2));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text('Set target cost'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixIcon: Icon(Icons.attach_money),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final newVal = double.tryParse(controller.text);
      if (newVal == null || newVal <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      setState(() => _targetCost = newVal);
    }
  }

  // Load existing saved plan for selected date (if any)
  Future<void> _loadExistingPlanForDate() async {
    final data =
    await AppDatabase.instance.getOrderPlanByDate(_formattedDate);

    if (data == null) {
      setState(() {
        _selectedFoodIds.clear();
        _currentTotal = 0.0;
        _targetCost = 0.0;
        _isEditing = true;
      });
      return;
    }

    final plan = data['plan'] as OrderPlan;
    final foods = data['foods'] as List<FoodItem>;

    setState(() {
      _targetCost = plan.targetCost;
      _selectedFoodIds = foods.map((f) => f.id!).toSet();
      _currentTotal = foods.fold(0.0, (sum, item) => sum + item.price);
      _isEditing = false; // plan exists → start in view mode
    });
  }

  // Toggle selection of food item while ensuring budget limit
  void _toggleSelection(FoodItem item) {
    if (!_isEditing) return;

    final isSelected = _selectedFoodIds.contains(item.id);
    final newTotal =
        _currentTotal + (isSelected ? -item.price : item.price);

    if (!isSelected && _targetCost > 0 && newTotal > _targetCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selection would exceed target cost')),
      );
      return;
    }

    setState(() {
      if (isSelected) {
        _selectedFoodIds.remove(item.id);
      } else {
        _selectedFoodIds.add(item.id!);
      }
      _currentTotal = newTotal;
    });
  }

  // Save order plan for selected date to local DB
  Future<void> _savePlan() async {
    if (_targetCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set a budget before saving')),
      );
      return;
    }
    if (_selectedFoodIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one food item')),
      );
      return;
    }

    await AppDatabase.instance.saveOrderPlan(
      date: _formattedDate,
      targetCost: _targetCost,
      selectedFoodIds: _selectedFoodIds.toList(),
    );

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order plan saved')),
    );
  }

  // Switch to edit mode to modify food selections
  void _enableFoodEditing() {
    setState(() => _isEditing = true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Order Planner'),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top buttons: View plans + Manage items
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('View plans'),
                        onPressed: () {
                          Navigator.pushNamed(
                              context, ViewPlanScreen.routeName);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text('Manage items'),
                        onPressed: () async {
                          await Navigator.pushNamed(
                              context, ManageFoodScreen.routeName);
                          await _loadFoodItems();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Date + budget card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Plan date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _formattedDate,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _pickDate,
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Budget',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '\$${_targetCost.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            FilledButton(
                              onPressed: _showBudgetDialog,
                              child: const Text('Set budget'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: \$${_currentTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Remaining: \$${_remaining.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _remaining <= 0
                                    ? scheme.error
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select food items',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Food list
                Expanded(
                  child: ListView.builder(
                    itemCount: _foodItems.length,
                    itemBuilder: (context, index) {
                      final item = _foodItems[index];
                      final selected = _selectedFoodIds.contains(item.id);

                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: _isEditing
                              ? () => _toggleSelection(item)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              enabled: _isEditing,
                              leading: Icon(
                                Icons.fastfood,
                                color: selected
                                    ? scheme.primary
                                    : Colors.grey.shade500,
                              ),
                              title: Text(item.name),
                              subtitle: Text(
                                  '\$${item.price.toStringAsFixed(2)}'),
                              trailing: Checkbox(
                                value: selected,
                                onChanged: _isEditing
                                    ? (_) => _toggleSelection(item)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: Icon(_isEditing ? Icons.save : Icons.edit),
                    label: Text(
                        _isEditing ? 'Save order plan' : 'Edit food plan'),
                    onPressed:
                    _isEditing ? _savePlan : _enableFoodEditing,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
