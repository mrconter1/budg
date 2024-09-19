import 'package:flutter/material.dart';
import '../budget/budget_models.dart';
import '../app_colors.dart';

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
              decoration: InputDecoration(
                hintText: 'Enter weekly budget',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryLight),
                ),
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
                          child: Text('Cancel', style: TextStyle(color: AppColors.textLight)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Reset', style: TextStyle(color: AppColors.budgetNegative)),
                          onPressed: () {
                            widget.onResetWeek();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Week reset successfully'),
                                backgroundColor: AppColors.budgetPositive,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.budgetNegative,
                foregroundColor: AppColors.textDark,
              ),
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