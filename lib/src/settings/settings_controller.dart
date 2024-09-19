import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_service.dart';

class SettingsController extends StateNotifier<ThemeMode> {
  SettingsController(this._settingsService) : super(ThemeMode.system);

  final SettingsService _settingsService;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => state;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    state = await _settingsService.themeMode();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == state) return;

    // Otherwise, store the new ThemeMode in memory
    state = newThemeMode;

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }
}