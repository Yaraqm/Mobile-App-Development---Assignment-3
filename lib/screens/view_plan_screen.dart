// view_plan_screen.dart
// Query screen: view existing order plan for a selected date.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/app_database.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';

class ViewPlanScreen extends StatefulWidget {
  static const routeName = '/view-plan';

  const ViewPlanScreen({super.key});

  @override
  State<ViewPlanScreen> createState() => _ViewPlanScreenState();
}

class _ViewPlanScreenState extends State<ViewPlanScreen> {
  DateTime _selectedDate = DateTime.now();
  OrderPlan? _plan;
  List<FoodItem> _foods = [];
  bool _isLoading = false;

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  // Opens date picker to select date for plan query
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadPlan();
    }
  }

  // Fetches plan and related food items from DB for selected date
  Future<void> _loadPlan() async {
    setState(() => _isLoading = true);

    final data = await AppDatabase.instance.getOrderPlanByDate(_formattedDate);

    if (!mounted) return;

    setState(() {
      if (data == null) {
        _plan = null;
        _foods = [];
      } else {
        _plan = data['plan'] as OrderPlan;
        _foods = data['foods'] as List<FoodItem>;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Order Plan'),
        actions: [
          // Search icon to pick another date
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search by date',
            onPressed: _pickDate,
          ),
        ],
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
                // Card showing current selected date
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month, color: scheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select date',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formattedDate,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: scheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.edit_calendar),
                          label: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Content section based on query result
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _plan == null
                      ? Center(
                    child: Text(
                      'No order plan found for $_formattedDate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Display plan summary with totals
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Plan summary',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Target cost: \$${_plan!.targetCost.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Actual total: \$${_foods.fold<double>(0, (s, f) => s + f.price).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Food items',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // List of food items under the plan
                      Expanded(
                        child: ListView.builder(
                          itemCount: _foods.length,
                          itemBuilder: (context, index) {
                            final item = _foods[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(Icons.fastfood,
                                    color: scheme.primary),
                                title: Text(item.name),
                                subtitle: Text(
                                  '\$${item.price.toStringAsFixed(2)}',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
