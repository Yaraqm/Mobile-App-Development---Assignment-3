// main.dart
// Entry point of the Food Ordering App, defining routes, themes, and structure.
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/manage_food_screen.dart';
import 'screens/view_plan_screen.dart';

void main() {
  runApp(const FoodOrderingApp());
}

// Root widget configuring overall app theme and navigation
class FoodOrderingApp extends StatelessWidget {
  const FoodOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Order Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Pastel lavender color scheme for a soft, modern UI
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

        // Consistent button styling across screens
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
      // Define navigation routes
      home: const HomeScreen(),
      routes: {
        ManageFoodScreen.routeName: (_) => const ManageFoodScreen(),
        ViewPlanScreen.routeName: (_) => const ViewPlanScreen(),
      },
    );
  }
}
