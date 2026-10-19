import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finny_pet/app/theme.dart';
import 'package:finny_pet/features/onboarding/onboarding_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: AppTheme.light, home: child);
}

void main() {
  testWidgets('Onboarding показывает заголовок', (tester) async {
    await tester.pumpWidget(_wrap(const OnboardingScreen()));
    expect(find.text('Познакомься с Финни!'), findsOneWidget);
  });

  testWidgets('Onboarding показывает кнопку Далее', (tester) async {
    await tester.pumpWidget(_wrap(const OnboardingScreen()));
    expect(find.text('Далее'), findsOneWidget);
  });

  testWidgets('Onboarding показывает кнопку Пропустить', (tester) async {
    await tester.pumpWidget(_wrap(const OnboardingScreen()));
    expect(find.text('Пропустить'), findsOneWidget);
  });

  testWidgets('Нажатие Далее переключает страницу', (tester) async {
    await tester.pumpWidget(_wrap(const OnboardingScreen()));
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    expect(find.text('Три типа решений'), findsOneWidget);
  });

  testWidgets('Вторая страница показывает 3 типа решений', (tester) async {
    await tester.pumpWidget(_wrap(const OnboardingScreen()));
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    expect(find.text('Обязательные'), findsOneWidget);
    expect(find.text('Необязательные'), findsOneWidget);
    expect(find.text('Накопления'), findsOneWidget);
  });
}
