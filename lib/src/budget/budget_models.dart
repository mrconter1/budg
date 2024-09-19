class BudgetDay {
  final String dayName;
  final List<Expense> expenses;

  BudgetDay(this.dayName, [List<Expense>? expenses])
      : expenses = expenses ?? [];

  double get totalSpent => expenses.fold(0, (sum, expense) => sum + expense.amount);
}

class Expense {
  final String description;
  final double amount;

  Expense(this.description, this.amount);
}