import 'package:flutter/material.dart';
import 'package:new_expense_tracker/models/expense.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';
import '../expense_screen/expense_card.dart';
import '../expense_screen/edit_expense_form.dart'; // Assuming this is where the form is

class AllExpensesList extends StatelessWidget {
  const AllExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        var list = db.expenses;
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              list.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        itemCount: list.length,
                        itemBuilder: (_, i) => ExpenseCard(
                          exp: list[i], // Pass the expense object
                          onEdit: (Expense expense) {
                            // Navigate to an edit screen with the current expense
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditExpenseForm(
                                  expense: expense,
                                  onSave: (updatedExpense) {
                                  },
                                ),
                              ),
                            );
                          },
                          onDelete: (Expense expense) {
                            // Call the database provider to delete the expense
                            db.deleteExpense(expense.id, expense.category, expense.amount);
                          },
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('No Entries Found'),
                    ),
            ],
          ),
        );
      },
    );
  }
}
