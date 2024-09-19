import 'package:flutter/material.dart';
import 'budget_models.dart';

class QuickExpenseEntry extends StatefulWidget {
  final List<BudgetDay> weekDays;
  final Function(int, double) onAddExpense;

  const QuickExpenseEntry({
    Key? key,
    required this.weekDays,
    required this.onAddExpense,
  }) : super(key: key);

  @override
  _QuickExpenseEntryState createState() => _QuickExpenseEntryState();
}

class _QuickExpenseEntryState extends State<QuickExpenseEntry> {
  late int _selectedDayIndex;
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = DateTime.now().weekday - 1; // 0-6, where 0 is Monday
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Expense',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedDayIndex,
              items: List.generate(
                widget.weekDays.length,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text(widget.weekDays[index].dayName),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedDayIndex = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Day',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (kr)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onAddExpense(
                    _selectedDayIndex,
                    double.parse(_amountController.text),
                  );
                }
              },
              child: const Text('Add Expense'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}