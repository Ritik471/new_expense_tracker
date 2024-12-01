import 'package:flutter/material.dart';
import 'expense_card.dart';
import '../../models/expense.dart';
import './edit_expense_form.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final Function(Expense) onEdit;
  final Function(Expense) onDelete;

  const ExpenseList({
    super.key,
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
  });

  void _openEditForm(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (_) => EditExpenseForm(
        expense: expense,
        onSave: (updatedExpense) {
          onEdit(updatedExpense); // Notify parent to update the expense
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'No expenses found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        return ExpenseCard(
          exp: expenses[index], // Pass the expense data
          onEdit: (expense) => _openEditForm(context, expense), // Open edit form
          onDelete: onDelete, // Notify parent to delete the expense
        );
      },
    );
  }
}
