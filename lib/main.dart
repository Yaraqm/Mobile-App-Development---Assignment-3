// main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/manage_food_screen.dart';
import 'screens/view_plan_screen.dart';

void main() {
  runApp(const FoodOrderingApp());
}

class FoodOrderingApp extends StatelessWidget {
  const FoodOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Order Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Pastel lavender style
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF7C4DFF),   // soft purple
          onPrimary: Colors.white,
          secondary: const Color(0xFFFF80AB), // pink accent
          surface: const Color(0xFFFFFFFF),
          onSurface: Colors.black87,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F0FF),
        cardTheme: CardThemeData(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          color: Colors.white,
          shadowColor: Colors.black26,
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            elevation: 5,
            shadowColor: Colors.black26,
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFFF6F0FF),
          foregroundColor: Colors.black87,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
      routes: {
        ManageFoodScreen.routeName: (_) => const ManageFoodScreen(),
        ViewPlanScreen.routeName: (_) => const ViewPlanScreen(),
      },
    );
  }
}
