class BudgetDay {
  final String dayName;
  List<Expense> expenses;

  BudgetDay(this.dayName, [this.expenses = const []]);

  double get totalSpent => expenses.fold(0, (sum, expense) => sum + expense.amount);
}

class Expense {
  final String description;
  final double amount;

  Expense(this.description, this.amount);
}