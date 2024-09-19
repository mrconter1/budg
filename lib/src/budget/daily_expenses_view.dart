import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'budget_models.dart';

class DailyExpensesView extends ConsumerWidget {
  final BudgetDay day;
  final Function(int) onRemoveExpense;

  const DailyExpensesView({
    Key? key,
    required this.day,
    required this.onRemoveExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${day.dayName} Expenses'),
      ),
      body: Column(
        children: [
          _buildDaySummary(context),
          Expanded(
            child: ListView.builder(
              itemCount: day.expenses.length,
              itemBuilder: (context, index) {
                final expense = day.expenses[index];
                return _buildExpenseCard(context, expense, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            day.dayName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Total Spent: ${day.totalSpent.toStringAsFixed(2)} kr',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${day.expenses.length} expense${day.expenses.length != 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense, int index) {
    return Dismissible(
      key: Key(expense.hashCode.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onRemoveExpense(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense of ${expense.amount.toStringAsFixed(2)} kr removed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Implement undo functionality here
              },
            ),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Text(
              '${index + 1}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          title: Text(
            '${expense.amount.toStringAsFixed(2)} kr',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              onRemoveExpense(index);
            },
          ),
        ),
      ),
    );
  }
}