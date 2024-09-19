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
  final List<BudgetDay> weekDays = [
    BudgetDay('Monday'),
    BudgetDay('Tuesday'),
    BudgetDay('Wednesday'),
    BudgetDay('Thursday'),
    BudgetDay('Friday'),
    BudgetDay('Saturday'),
    BudgetDay('Sunday'),
  ];

  void _addExpense(int dayIndex, Expense expense) {
    setState(() {
      weekDays[dayIndex] = BudgetDay(
        weekDays[dayIndex].dayName,
        [...weekDays[dayIndex].expenses, expense],
      );
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
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
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
            trailing: Text('\$${day.totalSpent.toStringAsFixed(2)}'),
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