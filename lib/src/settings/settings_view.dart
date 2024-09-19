// File: settings_view.dart

import 'package:flutter/material.dart';
import '../budget/budget_models.dart';

class SettingsView extends StatefulWidget {
  final VoidCallback onResetWeek;
  final WeeklyBudget weeklyBudget;
  final Function(double) onUpdateBudget;

  const SettingsView({
    Key? key,
    required this.onResetWeek,
    required this.weeklyBudget,
    required this.onUpdateBudget,
  }) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(text: widget.weeklyBudget.amount.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Weekly Budget (kr)'),
            subtitle: TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter weekly budget',
              ),
              onChanged: (value) {
                double? newBudget = double.tryParse(value);
                if (newBudget != null) {
                  widget.onUpdateBudget(newBudget);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Reset Week'),
            subtitle: const Text('Clear all expenses for the current week'),
            trailing: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Reset Week'),
                      content: const Text('Are you sure you want to reset all expenses for this week?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Reset'),
                          onPressed: () {
                            widget.onResetWeek();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }
}