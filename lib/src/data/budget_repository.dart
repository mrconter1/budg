import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../budget/budget_models.dart';

abstract class BudgetRepository {
  Future<WeeklyBudgetState> loadBudgetState();
  Future<void> saveBudgetState(WeeklyBudgetState state);
  Future<List<WeeklyBudgetHistory>> loadBudgetHistory();
  Future<void> saveBudgetHistory(List<WeeklyBudgetHistory> history);
  Future<void> checkAndResetBudget();
}

class LocalBudgetRepository implements BudgetRepository {
  static const String _stateKey = 'budget_state';
  static const String _historyKey = 'budget_history';
  static const String _lastResetKey = 'last_reset';

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
    return [];
  }

  @override
  Future<void> saveBudgetHistory(List<WeeklyBudgetHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = json.encode(history.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, historyJson);
  }

  @override
  Future<void> checkAndResetBudget() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final lastResetString = prefs.getString(_lastResetKey);
    final lastReset = lastResetString != null ? DateTime.parse(lastResetString) : null;

    if (lastReset == null || _shouldReset(now, lastReset)) {
      final currentState = await loadBudgetState();
      await _archiveCurrentWeek(currentState);
      
      final newState = WeeklyBudgetState(
        weekDays: createNewWeek(),
        weeklyBudget: currentState.weeklyBudget,
      );
      await saveBudgetState(newState);
      await prefs.setString(_lastResetKey, now.toIso8601String());
    }
  }

  bool _shouldReset(DateTime now, DateTime lastReset) {
    // Reset if it's past Sunday midnight and the last reset was before Sunday
    return now.weekday == DateTime.monday && lastReset.weekday != DateTime.monday && now.difference(lastReset).inHours >= 24;
  }

  Future<void> _archiveCurrentWeek(WeeklyBudgetState currentState) async {
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

    history.insert(0, weekHistory);
    
    // Optionally, limit the history to a certain number of weeks (e.g., 12 weeks)
    if (history.length > 12) {
      history.removeLast();
    }

    await saveBudgetHistory(history);
  }

  int _getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}