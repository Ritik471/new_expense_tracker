import 'package:flutter/material.dart';
import '../../models/expense.dart';

class EditExpenseForm extends StatelessWidget {
  final Expense expense;
  final Function(Expense) onSave;

  const EditExpenseForm({required this.expense, required this.onSave, super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController(text: expense.title);
    final TextEditingController amountController = TextEditingController(text: expense.amount.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update the expense object and call onSave
                final updatedExpense = Expense(
                  id: expense.id,
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  date: expense.date,
                  category: expense.category,
                );
                onSave(updatedExpense); // Trigger the callback to save the updated expense
                Navigator.of(context).pop(); // Close the edit form
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
