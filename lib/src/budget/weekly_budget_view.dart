import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_view.dart';
import 'budget_models.dart';
import 'daily_expenses_view.dart';
import 'expense_entry.dart';
import '../data/budget_repository.dart';
import '../app_colors.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) => LocalBudgetRepository());

final weeklyBudgetProvider = StateNotifierProvider<WeeklyBudgetNotifier, WeeklyBudgetState>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return WeeklyBudgetNotifier(repository);
});

class WeeklyBudgetNotifier extends StateNotifier<WeeklyBudgetState> {
  final BudgetRepository _repository;

  WeeklyBudgetNotifier(this._repository) : super(WeeklyBudgetState(weekDays: createNewWeek(), weeklyBudget: WeeklyBudget(1000))) {
    _loadState();
  }

  Future<void> _loadState() async {
    state = await _repository.loadBudgetState();
  }

  void addExpense(int dayIndex, double amount) {
    final updatedWeekDays = [...state.weekDays];
    final updatedDay = BudgetDay(
      state.weekDays[dayIndex].dayName,
      [...state.weekDays[dayIndex].expenses, Expense(amount)],
    );
    updatedWeekDays[dayIndex] = updatedDay;
    state = WeeklyBudgetState(weekDays: updatedWeekDays, weeklyBudget: state.weeklyBudget);
    _saveState();
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
    _saveState();
  }

  void resetWeek() {
    state = WeeklyBudgetState(weekDays: createNewWeek(), weeklyBudget: state.weeklyBudget);
    _saveState();
  }

  void updateBudget(double newBudget) {
    state = WeeklyBudgetState(weekDays: state.weekDays, weeklyBudget: WeeklyBudget(newBudget));
    _saveState();
  }

  Future<void> _saveState() async {
    await _repository.saveBudgetState(state);
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
                return _buildDayCard(context, day, index);
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
              return ExpenseEntry(
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
    final remainingPercentage = (remainingBudget / totalBudget).clamp(0.0, 1.0);
    
    // Create a color that transitions from budgetPositive to budgetNegative
    Color getColorForPercentage(double percentage) {
      return Color.lerp(AppColors.budgetNegative, AppColors.budgetPositive, percentage)!;
    }

    final progressColor = getColorForPercentage(remainingPercentage);
    
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
            color: AppColors.textLight.withOpacity(0.3),
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
          SizedBox(
            height: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(
                    color: AppColors.progressBarBackground,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: remainingPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

  Widget _buildDayCard(BuildContext context, BudgetDay day, int index) {
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
                color: day.totalSpent > 0 ? AppColors.budgetNegative : AppColors.budgetPositive,
              ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyExpensesView(
                dayIndex: index,
              ),
            ),
          );
        },
      ),
    );
  }
}