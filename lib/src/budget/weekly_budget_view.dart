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

  @override
  void initState() {
    super.initState();
    weekDays = createNewWeek();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final shouldReset = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => SettingsView(onResetWeek: _resetWeek)),
              );
              if (shouldReset == true) {
                _resetWeek();
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
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
    );
  }
}