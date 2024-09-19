// File: weekly_budget_view.dart

import 'package:flutter/material.dart';
import '../settings/settings_view.dart';
import 'budget_models.dart';
import 'daily_expenses_view.dart';

class WeeklyBudgetListView extends StatefulWidget {
  static const routeName = '/';

  @override
  _WeeklyBudgetListViewState createState() => _WeeklyBudgetListViewState();
}

class _WeeklyBudgetListViewState extends State<WeeklyBudgetListView> {
  late List<BudgetDay> weekDays;
  late WeeklyBudget weeklyBudget;

  @override
  void initState() {
    super.initState();
    weekDays = createNewWeek();
    weeklyBudget = WeeklyBudget(1000); // Default budget of 1000 kr
  }

  void _addExpense(int dayIndex, Expense expense) {
    setState(() {
      weekDays[dayIndex] = BudgetDay(
        weekDays[dayIndex].dayName,
        [...weekDays[dayIndex].expenses, expense],
      );
    });
  }

  void _resetWeek() {
    setState(() {
      weekDays = createNewWeek();
    });
  }

  void _updateBudget(double newBudget) {
    setState(() {
      weeklyBudget.amount = newBudget;
    });
  }

  @override
  Widget build(BuildContext context) {
    double remainingBudget = weeklyBudget.remainingBudget(weekDays);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsView(
                    onResetWeek: _resetWeek,
                    weeklyBudget: weeklyBudget,
                    onUpdateBudget: _updateBudget,
                  ),
                ),
              );
              if (result == true) {
                _resetWeek();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              restorationId: 'weeklyBudgetListView',
              itemCount: weekDays.length,
              itemBuilder: (BuildContext context, int index) {
                final day = weekDays[index];
                return ListTile(
                  title: Text(day.dayName),
                  trailing: Text('${day.totalSpent.toStringAsFixed(2)} kr'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyExpensesView(
                          day: day,
                          onAddExpense: (expense) => _addExpense(index, expense),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColorLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weekly Budget: ${weeklyBudget.amount.toStringAsFixed(2)} kr'),
                Text(
                  'Remaining: ${remainingBudget.toStringAsFixed(2)} kr',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: remainingBudget < 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}