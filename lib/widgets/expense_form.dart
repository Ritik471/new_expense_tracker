import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/database_provider.dart';
import '../../../constants/icons.dart';
import '../../../models/expense.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>(); 
  final _title = TextEditingController();
  final _amount = TextEditingController();
  DateTime? _date;
  String _initialValue = 'Other';

  // Pick a date
  _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey, 
          child: Column(
            children: [
            
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Title of expense',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title for the expense';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),

             
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount of expense',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _date != null
                          ? DateFormat('MMMM dd, yyyy').format(_date!)
                          : 'Select Date',
                      style: TextStyle(
                          color: _date != null ? const Color.fromARGB(255, 255, 253, 253) : Colors.red),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _pickDate(),
                    icon: const Icon(Icons.calendar_month),
                  ),
                ],
              ),
              if (_date == null)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Please select a date',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20.0),

              
              Row(
                children: [
                  const Expanded(child: Text('Category')),
                  Expanded(
                    child: DropdownButton(
                      items: icons.keys
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      value: _initialValue,
                      onChanged: (newValue) {
                        setState(() {
                          _initialValue = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // Add Expense button
              ElevatedButton.icon(
  onPressed: () {
    if (_formKey.currentState!.validate() && _date != null) {
     
      final file = Expense(
        id: 0,
        title: _title.text,
        amount: double.parse(_amount.text),
        date: _date!,
        category: _initialValue,
      );

      
      provider.addExpense(file);

      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      // Close the bottom sheet
      Navigator.of(context).pop();
    } else if (_date == null) {
      setState(() {}); // Refresh UI to show date error
    }
  },
  icon: const Icon(Icons.add),
  label: const Text('Add Expense'),
),
            ],
          ),
        ),
      ),
    );
  }
}
