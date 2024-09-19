import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_view.dart';
import 'budget_models.dart';
import 'daily_expenses_view.dart';

final weeklyBudgetProvider = StateNotifierProvider<WeeklyBudgetNotifier, WeeklyBudgetState>((ref) {
  return WeeklyBudgetNotifier();
});

class WeeklyBudgetState {
  final List<BudgetDay> weekDays;
  final WeeklyBudget weeklyBudget;

  WeeklyBudgetState({required this.weekDays, required this.weeklyBudget});
}

class WeeklyBudgetNotifier extends StateNotifier<WeeklyBudgetState> {
  WeeklyBudgetNotifier() : super(WeeklyBudgetState(weekDays: createNewWeek(), weeklyBudget: WeeklyBudget(1000)));

  void addExpense(int dayIndex, Expense expense) {
    final updatedWeekDays = [...state.weekDays];
    final updatedDay = BudgetDay(
      state.weekDays[dayIndex].dayName,
      [...state.weekDays[dayIndex].expenses, expense],
    );
    updatedWeekDays[dayIndex] = updatedDay;
    state = WeeklyBudgetState(weekDays: updatedWeekDays, weeklyBudget: state.weeklyBudget);
  }

  void resetWeek() {
    state = WeeklyBudgetState(weekDays: createNewWeek(), weeklyBudget: state.weeklyBudget);
  }

  void updateBudget(double newBudget) {
    state = WeeklyBudgetState(weekDays: state.weekDays, weeklyBudget: WeeklyBudget(newBudget));
  }
}

class WeeklyBudgetListView extends ConsumerWidget {
  static const routeName = '/';

  const WeeklyBudgetListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weeklyBudgetProvider);
    final notifier = ref.read(weeklyBudgetProvider.notifier);
    final remainingBudget = state.weeklyBudget.remainingBudget(state.weekDays);

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
                    onResetWeek: notifier.resetWeek,
                    weeklyBudget: state.weeklyBudget,
                    onUpdateBudget: notifier.updateBudget,
                  ),
                ),
              );
              if (result == true) {
                notifier.resetWeek();
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
              itemCount: state.weekDays.length,
              itemBuilder: (BuildContext context, int index) {
                final day = state.weekDays[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(day.dayName, style: Theme.of(context).textTheme.titleMedium),
                    trailing: Text(
                      '${day.totalSpent.toStringAsFixed(2)} kr',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DailyExpensesView(
                            day: day,
                            onAddExpense: (expense) => notifier.addExpense(index, expense),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Budget: ${state.weeklyBudget.amount.toStringAsFixed(2)} kr',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Remaining: ${remainingBudget.toStringAsFixed(2)} kr',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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