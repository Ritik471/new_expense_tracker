
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';
import './expense_list.dart';
import './expense_chart.dart';
import '../../models/expense.dart';

class ExpenseFetcher extends StatefulWidget {
  final String category;
  const ExpenseFetcher(this.category, {super.key});

  @override
  State<ExpenseFetcher> createState() => _ExpenseFetcherState();
}

class _ExpenseFetcherState extends State<ExpenseFetcher> {
  late Future _expenseListFuture;
  List<Expense> _expenses = [];

  Future<void> _fetchExpenses() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final fetchedExpenses = await provider.fetchExpenses(widget.category);
    setState(() {
      _expenses = fetchedExpenses;
    });
  }

  @override
  void initState() {
    super.initState();
    _expenseListFuture = _fetchExpenses();
  }

  void _editExpense(Expense updatedExpense) {
    setState(() {
      final index = _expenses.indexWhere((exp) => exp.id == updatedExpense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
    });
  }
void _deleteExpense(Expense expense) async {
  final provider = Provider.of<DatabaseProvider>(context, listen: false);

  try {
    // Delete the expense
    await provider.deleteExpense(expense.id, expense.category, expense.amount);

    // Refetch the updated list of expenses
    _expenseListFuture = _fetchExpenses();
    setState(() {});
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete expense: $error')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _expenseListFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 250.0,
                    child: ExpenseChart(widget.category),
                  ),
                  Expanded(
                    child: ExpenseList(
                      expenses: _expenses,
                      onEdit: _editExpense,
                      onDelete: _deleteExpense,
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}