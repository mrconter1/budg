import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_view.dart';
import 'budget_models.dart';
import 'daily_expenses_view.dart';
import 'quick_expense_entry.dart';

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

  void addExpense(int dayIndex, double amount) {
    final updatedWeekDays = [...state.weekDays];
    final updatedDay = BudgetDay(
      state.weekDays[dayIndex].dayName,
      [...state.weekDays[dayIndex].expenses, Expense(amount)],
    );
    updatedWeekDays[dayIndex] = updatedDay;
    state = WeeklyBudgetState(weekDays: updatedWeekDays, weeklyBudget: state.weeklyBudget);
  }

  void removeExpense(int dayIndex, int expenseIndex) {
    final updatedWeekDays = [...state.weekDays];
    final updatedExpenses = List<Expense>.from(state.weekDays[dayIndex].expenses);
    updatedExpenses.removeAt(expenseIndex);
    final updatedDay = BudgetDay(
      state.weekDays[dayIndex].dayName,
      updatedExpenses,
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
          _buildBudgetOverview(context, state.weeklyBudget.amount, remainingBudget),
          Expanded(
            child: ListView.builder(
              restorationId: 'weeklyBudgetListView',
              itemCount: state.weekDays.length,
              itemBuilder: (BuildContext context, int index) {
                final day = state.weekDays[index];
                return _buildDayCard(context, day, index, notifier);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return QuickExpenseEntry(
                weekDays: state.weekDays,
                onAddExpense: (dayIndex, amount) {
                  notifier.addExpense(dayIndex, amount);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetOverview(BuildContext context, double totalBudget, double remainingBudget) {
    final percentage = (remainingBudget / totalBudget).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Budget Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBudgetItem(context, 'Total', totalBudget),
              _buildBudgetItem(context, 'Remaining', remainingBudget),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.25 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(BuildContext context, String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} kr',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, BudgetDay day, int index, WeeklyBudgetNotifier notifier) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Text(
            day.dayName.substring(0, 2),
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          ),
        ),
        title: Text(day.dayName, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text('${day.expenses.length} expenses'),
        trailing: Text(
          '${day.totalSpent.toStringAsFixed(2)} kr',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: day.totalSpent > 0 ? Colors.red : Colors.green,
              ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyExpensesView(
                day: day,
                onRemoveExpense: (expenseIndex) => notifier.removeExpense(index, expenseIndex),
              ),
            ),
          );
        },
      ),
    );
  }
}