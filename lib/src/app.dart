import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'budget/weekly_budget_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_service.dart';
import 'data/budget_repository.dart';
import 'app_colors.dart';  // Import the new app_colors.dart file

final settingsServiceProvider = Provider<SettingsService>((ref) => SettingsService());

final settingsControllerProvider = StateNotifierProvider<SettingsController, ThemeMode>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return SettingsController(settingsService);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) => LocalBudgetRepository());

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsControllerProvider);

    return MaterialApp(
      restorationScopeId: 'app',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,
      theme: FlexThemeData.light(
        colors: FlexSchemeColor(
          primary: AppColors.primaryLight,
          primaryContainer: AppColors.primaryLight.withOpacity(0.7),
          secondary: AppColors.secondaryLight,
          secondaryContainer: AppColors.secondaryLight.withOpacity(0.7),
          tertiary: AppColors.budgetPositive,
          error: AppColors.errorLight,
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 9,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        background: AppColors.backgroundLight,
      ),
      darkTheme: FlexThemeData.dark(
        colors: FlexSchemeColor(
          primary: AppColors.primaryDark,
          primaryContainer: AppColors.primaryDark.withOpacity(0.7),
          secondary: AppColors.secondaryDark,
          secondaryContainer: AppColors.secondaryDark.withOpacity(0.7),
          tertiary: AppColors.budgetPositive,
          error: AppColors.errorDark,
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 15,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        background: AppColors.backgroundDark,
      ),
      themeMode: themeMode,
      home: const WeeklyBudgetListView(),
    );
  }
}