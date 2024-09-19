class BudgetDay {
  final String dayName;
  final List<Expense> expenses;

  BudgetDay(this.dayName, [List<Expense>? expenses])
      : expenses = expenses ?? [];

  double get totalSpent => expenses.fold(0, (sum, expense) => sum + expense.amount);
}

class Expense {
  final double amount;

  Expense(this.amount);
}

class WeeklyBudget {
  double amount;

  WeeklyBudget(this.amount);

  double remainingBudget(List<BudgetDay> weekDays) {
    double totalSpent = weekDays.fold(0, (sum, day) => sum + day.totalSpent);
    return amount - totalSpent;
  }
}

List<BudgetDay> createNewWeek() {
  return [
    BudgetDay('Monday'),
    BudgetDay('Tuesday'),
    BudgetDay('Wednesday'),
    BudgetDay('Thursday'),
    BudgetDay('Friday'),
    BudgetDay('Saturday'),
    BudgetDay('Sunday'),
  ];
}