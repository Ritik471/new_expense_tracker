import 'package:flutter/material.dart';
import '../../models/expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense exp;
  final Function(Expense) onEdit; // Callback for editing
  final Function(Expense) onDelete; // Callback for deleting

  const ExpenseCard({
    required this.exp,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(exp.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.startToEnd, // Swipe to the right
      confirmDismiss: (direction) async {
        // Confirm dialog before deletion
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to remove this expense?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        // Call the onDelete function when dismissed
        onDelete(exp);
      },
      child: ListTile(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.category), // Customize this icon dynamically
        ),
        title: Text(exp.title),
        subtitle: Text(exp.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Call the onEdit function with the current expense
                onEdit(exp);
              },
            ),
          ],
        ),
      ),
    );
  }
}
