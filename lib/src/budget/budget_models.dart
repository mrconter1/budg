// File: lib/budget/budget_models.dart

class BudgetDay {
  final String dayName;
  final List<Expense> expenses;

  BudgetDay(this.dayName, [List<Expense>? expenses])
      : expenses = expenses ?? [];

  double get totalSpent => expenses.fold(0, (sum, expense) => sum + expense.amount);

  Map<String, dynamic> toJson() => {
    'dayName': dayName,
    'expenses': expenses.map((e) => e.toJson()).toList(),
  };

  factory BudgetDay.fromJson(Map<String, dynamic> json) {
    return BudgetDay(
      json['dayName'],
      (json['expenses'] as List).map((e) => Expense.fromJson(e)).toList(),
    );
  }
}

class Expense {
  final double amount;

  Expense(this.amount);

  Map<String, dynamic> toJson() => {'amount': amount};

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(json['amount']);
  }
}

class WeeklyBudget {
  final double amount;

  WeeklyBudget(this.amount);

  double remainingBudget(List<BudgetDay> weekDays) {
    double totalSpent = weekDays.fold(0, (sum, day) => sum + day.totalSpent);
    return amount - totalSpent;
  }

  Map<String, dynamic> toJson() => {'amount': amount};

  factory WeeklyBudget.fromJson(Map<String, dynamic> json) {
    return WeeklyBudget(json['amount']);
  }
}

class WeeklyBudgetState {
  final List<BudgetDay> weekDays;
  final WeeklyBudget weeklyBudget;

  WeeklyBudgetState({required this.weekDays, required this.weeklyBudget});

  Map<String, dynamic> toJson() => {
    'weekDays': weekDays.map((day) => day.toJson()).toList(),
    'weeklyBudget': weeklyBudget.toJson(),
  };

  factory WeeklyBudgetState.fromJson(Map<String, dynamic> json) {
    return WeeklyBudgetState(
      weekDays: (json['weekDays'] as List).map((dayJson) => BudgetDay.fromJson(dayJson)).toList(),
      weeklyBudget: WeeklyBudget.fromJson(json['weeklyBudget']),
    );
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