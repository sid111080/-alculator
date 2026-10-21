import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finny_pet/app/theme.dart';
import 'package:finny_pet/core/models/pet_character.dart';
import 'package:finny_pet/core/models/player_profile.dart';
import 'package:finny_pet/core/services/game_engine.dart';
import 'package:finny_pet/core/services/storage_service.dart';
import 'package:finny_pet/core/services/task_service.dart';
import 'package:finny_pet/features/onboarding/onboarding_screen.dart';
import 'package:finny_pet/features/profile/profile_creation_screen.dart';
import 'package:finny_pet/features/pet_creation/pet_creation_screen.dart';
import 'package:finny_pet/features/home/home_screen.dart';
import 'package:finny_pet/features/budget/budget_screen.dart';
import 'package:finny_pet/features/tasks/tasks_screen.dart';
import 'package:finny_pet/features/purchases/purchases_screen.dart';
import 'package:finny_pet/features/savings/savings_screen.dart';
import 'package:finny_pet/features/progress/progress_screen.dart';
import 'package:finny_pet/features/adult/adult_screen.dart';

/// Smoke-тест по всем экранам. Каждый экран логируется ДО и ПОСЛЕ pump,
/// чтобы при зависании было видно, на каком именно экране он произошёл.
/// Используется pump() с фиксированной длительностью (НЕ pumpAndSettle),
/// чтобы повторяющиеся анимации не вешали тест.
void main() {
  final log = File('.qwen/tmp/smoke.log');
  void logLine(String s) {
    log.writeAsStringSync(s, mode: FileMode.append);
    debugPrint(s);
  }

  log.writeAsStringSync('=== smoke start ===\n');

  setUpAll(() async {
    logLine('INIT start');
    final dir = await Directory.systemTemp.createTemp('hive_smoke');
    await StorageService().initAt(dir.path);
    logLine('INIT storage ok');
    await GameEngine().init();
    logLine('INIT gameengine ok');
    await TaskService().init();
    logLine('INIT taskservice ok');
    final p = PlayerProfile.create(
      playerName: 'Гость',
      character: PetCharacter.reeko,
    );
    await StorageService().setActiveProfile(p);
    logLine('INIT done');
  });

  final screens = <String, Widget>{
    'Onboarding': const OnboardingScreen(),
    'Profile': const ProfileCreationScreen(),
    'PetCreation': const PetCreationScreen(),
    'Home': const HomeScreen(),
    'Budget': const BudgetScreen(),
    'Tasks': const TasksScreen(),
    'Purchases': const PurchasesScreen(),
    'Savings': const SavingsScreen(),
    'Progress': const ProgressScreen(),
    'Adult': const AdultScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} builds without exception', (tester) async {
      logLine('START ${entry.key}');
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: entry.value),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      final ex = tester.takeException();
      if (ex != null) {
        logLine('FAIL ${entry.key}: ${ex.runtimeType}: $ex');
      } else {
        logLine('OK ${entry.key}');
      }
      expect(ex, isNull, reason: '${entry.key} threw: $ex');
    });
  }

  logLine('=== smoke done ===');
}
