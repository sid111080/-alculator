import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finny_pet/app/theme.dart';
import 'package:finny_pet/core/services/game_engine.dart';
import 'package:finny_pet/core/services/storage_service.dart';
import 'package:finny_pet/core/services/task_service.dart';
import 'package:finny_pet/features/tasks/tasks_screen.dart';
import 'package:finny_pet/features/savings/savings_screen.dart';

/// Регрессионные тесты: экраны «Задания» и «Копилка» строятся без исключений.
///
/// Зафиксированы два бага (белый экран в release):
/// 1. Задания: `late MathTask? _activeTask` → LateInitializationError
///    (nullable `late` без инициализатора не становится null).
/// 2. Копилка: `final goal = _currentGoal!` → Null check on null,
///    когда goalName профиля не найден в каталоге целей.
void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_regression');
    await StorageService().initAt(dir.path);
    await GameEngine().init();
    await TaskService().init();
  });

  Widget _wrap(Widget child) =>
      MaterialApp(theme: AppTheme.light, home: child);

  testWidgets('TasksScreen строится без исключений', (tester) async {
    await tester.pumpWidget(_wrap(const TasksScreen()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(TasksScreen), findsOneWidget);
  });

  testWidgets('SavingsScreen строится без исключений (цель не выбрана)', (tester) async {
    await tester.pumpWidget(_wrap(const SavingsScreen()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(SavingsScreen), findsOneWidget);
    // Цель не выбрана → показывается экран выбора цели.
    expect(find.text('Выбери цель для копилки'), findsOneWidget);
  });
}
