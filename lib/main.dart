import 'package:new_expense_tracker/Authentication/signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './models/database_provider.dart';
import './screens/category_screen.dart';
import './screens/expense_screen.dart';
import './screens/all_expenses.dart';
import './Authentication/login.dart'; 

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => DatabaseProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key,});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),  
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: LoginScreen.name,
      routes: {
        CategoryScreen.name: (_) => const CategoryScreen(),
        ExpenseScreen.name: (_) => const ExpenseScreen(),
        AllExpenses.name: (_) => const AllExpenses(),
        LoginScreen.name: (_) => const LoginScreen(),
        SignUp.name: (_) => const LoginScreen(),
      },
    );
  }
}
