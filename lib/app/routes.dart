import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_creation_screen.dart';
import '../features/pet_creation/pet_creation_screen.dart';
import '../features/home/home_screen.dart';
import '../features/budget/budget_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../features/purchases/purchases_screen.dart';
import '../features/savings/savings_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/adult/adult_screen.dart';
import 'theme.dart';

/// Навигация приложения.
/// Tab-экраны обёрнуты в StatefulShellRoute — NavigationBar персистентна.
class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileCreationScreen(),
      ),
      GoRoute(
        path: '/pet_creation',
        builder: (context, state) => const PetCreationScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/budget', builder: (context, state) => const BudgetScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/tasks', builder: (context, state) => const TasksScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/purchases', builder: (context, state) => const PurchasesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/savings', builder: (context, state) => const SavingsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/progress', builder: (context, state) => const ProgressScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/adult', builder: (context, state) => const AdultScreen()),
          ]),
        ],
      ),
    ],
  );
}

/// Оболочка с персистентным NavigationBar.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SwipeRing(navigationShell: navigationShell),
      bottomNavigationBar: Container(
        // Тонкая верхняя граница (HUD-стиль)
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0x0D000000), width: 1),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            // Полупрозрачная подложка с эффектом размытия
            backgroundColor: Colors.white.withValues(alpha: 0.85),
            indicatorColor: AppTheme.hudBlue.withValues(alpha: 0.12),
            iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
                  size: 22,
                  color: states.contains(WidgetState.selected)
                      ? AppTheme.hudBlue
                      : AppTheme.textSecondary,
                )),
            labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                  fontSize: 10,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: states.contains(WidgetState.selected)
                      ? AppTheme.hudBlue
                      : AppTheme.textSecondary,
                )),
          ),
          child: NavigationBar(
            height: 64,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (i) => navigationShell.goBranch(i),
            destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Бюджет',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Задания',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag),
              label: 'Покупки',
            ),
            NavigationDestination(
              icon: Icon(Icons.savings_outlined),
              selectedIcon: Icon(Icons.savings),
              label: 'Копилка',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined),
              selectedIcon: Icon(Icons.trending_up),
              label: 'Прогресс',
            ),
            NavigationDestination(
              icon: Icon(Icons.lock_outline),
              selectedIcon: Icon(Icons.lock),
              label: 'Взрослый',
            ),
          ],
          ),
        ),
      ),
    );
  }
}

/// Экраны кольце — свайпо влево/право пераитсь по этой цикле круговорм
/// (послед → первь). Must match the StatefulShellRoute branches and the
/// NavigationBar destinations above.
const int ringSize = 7;

/// Minimum horizontal drag distance (logical px) that counts as a swipe.
const double _kSwipeMinDistance = 80;

/// Свайпо-кольцо: горизонтале пан на any screen of the ring switches the
/// branch. Swipe left → next screen, swipe right → previous screen.
class SwipeRing extends StatefulWidget {
  const SwipeRing({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<SwipeRing> createState() => _SwipeRingState();
}

class _SwipeRingState extends State<SwipeRing> {
  double _dx = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (_) => _dx = 0,
      onHorizontalDragUpdate: (data) => _dx += data.delta.dx,
      onHorizontalDragEnd: (_) => _commitSwipe(),
      child: widget.navigationShell,
    );
  }

  void _commitSwipe() {
    if (_dx.abs() < _kSwipeMinDistance) return;
    final dir = _dx < 0 ? 1 : -1;
    final current = widget.navigationShell.currentIndex;
    final next = (current + dir + ringSize) % ringSize;
    if (next != current) {
      widget.navigationShell.goBranch(next);
    }
    _dx = 0;
  }
}
