import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_view.dart';
import 'budget_models.dart';
import 'daily_expenses_view.dart';
import 'expense_entry.dart';
import '../data/budget_repository.dart';
import '../app_colors.dart';
import 'weekly_budget_history_view.dart';

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

  Future<void> resetWeek() async {
    await (_repository as LocalBudgetRepository).archiveCurrentWeek(state);
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
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, state.weeklyBudget.amount, remainingBudget, notifier),
          SliverToBoxAdapter(
            child: _buildBudgetOverview(context, state.weeklyBudget.amount, remainingBudget),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final day = state.weekDays[index];
                return _buildDayCard(context, day, index);
              },
              childCount: state.weekDays.length,
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'history',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeeklyBudgetHistoryView()),
              );
            },
            child: const Icon(Icons.history),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add',
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
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, double totalBudget, double remainingBudget, WeeklyBudgetNotifier notifier) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Weekly Budget',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBudgetItem(context, 'Total', totalBudget, true),
                  _buildBudgetItem(context, 'Remaining', remainingBudget, true),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsView(
                  onResetWeek: notifier.resetWeek,
                  weeklyBudget: WeeklyBudget(totalBudget),
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
    );
  }

  Widget _buildBudgetOverview(BuildContext context, double totalBudget, double remainingBudget) {
    final remainingPercentage = (remainingBudget / totalBudget).clamp(0.0, 1.0);
    
    Color getColorForPercentage(double percentage) {
      if (percentage > 0.5) {
        return Color.lerp(
          Colors.orange,
          AppColors.budgetPositive,
          (percentage - 0.5) * 2
        )!;
      } else {
        return Color.lerp(
          AppColors.budgetNegative,
          Colors.orange,
          percentage * 2
        )!;
      }
    }

    final progressColor = getColorForPercentage(remainingPercentage);
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
          const SizedBox(height: 8),
          Text(
            '${(remainingPercentage * 100).toStringAsFixed(1)}% remaining',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(BuildContext context, String label, double amount, bool isAppBar) {
    final textColor = isAppBar ? Colors.white : Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor.withOpacity(0.8),
              ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} kr',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, BudgetDay day, int index) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.dayName.substring(0, 2),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.dayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${day.expenses.length} expenses',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${day.totalSpent.toStringAsFixed(2)} kr',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: day.totalSpent > 0 ? AppColors.budgetNegative : AppColors.budgetPositive,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}