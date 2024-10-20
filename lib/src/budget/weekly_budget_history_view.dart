import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../budget/budget_models.dart';
import '../data/budget_repository.dart';
import '../app_colors.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: weekHistory.isSuccessful ? Colors.green.shade100 : Colors.red.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Week ${weekHistory.weekNumber}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: weekHistory.isSuccessful ? Colors.green.shade800 : Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(weekHistory.startDate),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: weekHistory.isSuccessful ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}