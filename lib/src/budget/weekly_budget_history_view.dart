import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'budget_models.dart';
import '../data/budget_repository.dart';
import '../app_colors.dart';
import 'package:intl/intl.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) => LocalBudgetRepository());

final weeklyBudgetHistoryProvider = FutureProvider<List<WeeklyBudgetHistory>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  return await repository.loadBudgetHistory();
});

class WeeklyBudgetHistoryView extends ConsumerWidget {
  const WeeklyBudgetHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsyncValue = ref.watch(weeklyBudgetHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget History'),
      ),
      body: historyAsyncValue.when(
        data: (history) => _buildHistoryList(context, history),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<WeeklyBudgetHistory> history) {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final weekHistory = history[index];
        return _buildWeekCard(context, weekHistory);
      },
    );
  }

  Widget _buildWeekCard(BuildContext context, WeeklyBudgetHistory weekHistory) {
    final remainingBudget = weekHistory.weeklyBudget.amount - weekHistory.totalSpent;
    final remainingPercentage = (remainingBudget / weekHistory.weeklyBudget.amount).clamp(0.0, 1.0);
    final progressColor = _getColorForPercentage(remainingPercentage);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Week ${weekHistory.weekNumber}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(weekHistory.startDate),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 1 - remainingPercentage,
              backgroundColor: AppColors.progressBarBackground,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Budget: ${weekHistory.weeklyBudget.amount.toStringAsFixed(2)} kr'),
                Text('Spent: ${weekHistory.totalSpent.toStringAsFixed(2)} kr'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Remaining: ${remainingBudget.toStringAsFixed(2)} kr',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: remainingBudget >= 0 ? AppColors.budgetPositive : AppColors.budgetNegative,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage > 0.5) {
      return Color.lerp(Colors.orange, AppColors.budgetPositive, (percentage - 0.5) * 2)!;
    } else {
      return Color.lerp(AppColors.budgetNegative, Colors.orange, percentage * 2)!;
    }
  }
}