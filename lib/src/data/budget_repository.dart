import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../budget/budget_models.dart';

abstract class BudgetRepository {
  Future<WeeklyBudgetState> loadBudgetState();
  Future<void> saveBudgetState(WeeklyBudgetState state);
  Future<List<WeeklyBudgetHistory>> loadBudgetHistory();
  Future<void> saveBudgetHistory(List<WeeklyBudgetHistory> history);
}

class LocalBudgetRepository implements BudgetRepository {
  static const String _stateKey = 'budget_state';
  static const String _historyKey = 'budget_history';

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

  @override
  Future<List<WeeklyBudgetHistory>> loadBudgetHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      final List<dynamic> historyList = json.decode(historyJson);
      return historyList.map((item) => WeeklyBudgetHistory.fromJson(item)).toList();
    }
    // If the history is empty, add sample data for the last three weeks
    return _createSampleHistory();
  }

  @override
  Future<void> saveBudgetHistory(List<WeeklyBudgetHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = json.encode(history.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, historyJson);
  }

  // Helper method to create sample history data
  List<WeeklyBudgetHistory> _createSampleHistory() {
    final currentDate = DateTime.now();
    List<WeeklyBudgetHistory> sampleHistory = [];

    for (int i = 3; i > 0; i--) {
      final weekStartDate = currentDate.subtract(Duration(days: 7 * i + currentDate.weekday - 1));
      int weekNumber = _getWeekNumber(weekStartDate);
      
      // Make the second week (i == 2) unsuccessful
      bool isSuccessful = i != 2;

      sampleHistory.add(WeeklyBudgetHistory(
        weekNumber: weekNumber,
        isSuccessful: isSuccessful,
        startDate: weekStartDate,
      ));
    }

    return sampleHistory;
  }

  // Helper method to archive the current week's budget
  Future<void> archiveCurrentWeek(WeeklyBudgetState currentState) async {
    final history = await loadBudgetHistory();
    final currentDate = DateTime.now();
    final weekStartDate = currentDate.subtract(Duration(days: currentDate.weekday - 1));
    
    int weekNumber = _getWeekNumber(weekStartDate);
    bool isSuccessful = currentState.weeklyBudget.remainingBudget(currentState.weekDays) >= 0;

    final weekHistory = WeeklyBudgetHistory(
      weekNumber: weekNumber,
      isSuccessful: isSuccessful,
      startDate: weekStartDate,
    );

    history.insert(0, weekHistory); // Add the current week to the beginning of the list
    
    // Optionally, limit the history to a certain number of weeks (e.g., 12 weeks)
    if (history.length > 12) {
      history.removeLast();
    }

    await saveBudgetHistory(history);
  }

  // Helper method to start a new week
  Future<void> startNewWeek() async {
    final currentState = await loadBudgetState();
    await archiveCurrentWeek(currentState);

    final newState = WeeklyBudgetState(
      weekDays: createNewWeek(),
      weeklyBudget: currentState.weeklyBudget, // Keep the same weekly budget
    );

    await saveBudgetState(newState);
  }

  // Helper method to calculate the week number
  int _getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat('D').format(date));
    int weekOfYear = ((dayOfYear - date.weekday + 10) / 7).floor();
    return weekOfYear;
  }
}