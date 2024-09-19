// File: lib/data/budget_repository.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../budget/budget_models.dart';

abstract class BudgetRepository {
  Future<WeeklyBudgetState> loadBudgetState();
  Future<void> saveBudgetState(WeeklyBudgetState state);
}

class LocalBudgetRepository implements BudgetRepository {
  static const String _stateKey = 'budget_state';

  @override
  Future<WeeklyBudgetState> loadBudgetState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? stateJson = prefs.getString(_stateKey);
    if (stateJson != null) {
      final Map<String, dynamic> stateMap = json.decode(stateJson);
      return WeeklyBudgetState.fromJson(stateMap);
    }
    // Return default state if no saved state is found
    return WeeklyBudgetState(weekDays: createNewWeek(), weeklyBudget: WeeklyBudget(1000));
  }

  @override
  Future<void> saveBudgetState(WeeklyBudgetState state) async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = json.encode(state.toJson());
    await prefs.setString(_stateKey, stateJson);
  }
}