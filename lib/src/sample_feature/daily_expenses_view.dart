import 'package:flutter/material.dart';
import 'sample_item.dart';

class DailyExpensesView extends StatefulWidget {
  final BudgetDay day;

  const DailyExpensesView({super.key, required this.day});

  @override
  _DailyExpensesViewState createState() => _DailyExpensesViewState();
}

class _DailyExpensesViewState extends State<DailyExpensesView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.day.dayName} Expenses'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.day.expenses.length,
              itemBuilder: (context, index) {
                final expense = widget.day.expenses[index];
                return ListTile(
                  title: Text(expense.description),
                  trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _addExpense,
                    child: const Text('Add Expense'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        widget.day.expenses.add(Expense(
          _descriptionController.text,
          double.parse(_amountController.text),
        ));
      });
      _descriptionController.clear();
      _amountController.clear();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}