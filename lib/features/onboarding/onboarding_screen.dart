import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

/// Экран онбординга — знакомство с игрой (3 страницы).
/// Требование 8.1: короткое знакомство с целью игры и тремя типами решений.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _current = 0;

  static const _pages = [
    OnboardingPage(
      emoji: '🐾',
      title: 'Познакомься с Финни!',
      subtitle:
          'Твой питомец растёт и развивается, когда ты правильно управляешь '
          'своими монетами. Корми, играй и планируй бюджет!',
    ),
    OnboardingPage(
      emoji: '💰',
      title: 'Три типа решений',
      subtitle: 'Каждый день ты делаешь выбор:',
      items: [
        OnboardingItem(
          icon: '🍎',
          label: 'Обязательные',
          description: 'Еда и уход — без них питомцу грустно',
          color: Color(0xFFE85D5D),
        ),
        OnboardingItem(
          icon: '🎮',
          label: 'Необязательные',
          description: 'Игрушки и развлечения — по желанию',
          color: Color(0xFFFF8C42),
        ),
        OnboardingItem(
          icon: '🏦',
          label: 'Накопления',
          description: 'Копим на большую цель',
          color: Color(0xFF4A90D9),
        ),
      ],
    ),
    OnboardingPage(
      emoji: '🌟',
      title: 'Как это работает',
      subtitle:
          'Получай монеты за задания → Планируй бюджет → Покупай и копи → '
          'Питомец растёт!',
      showSteps: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      context.go('/profile');
    }
  }

  void _skip() => context.go('/profile');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Кнопка пропустить
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 20),
                child: TextButton(
                  onPressed: _skip,
                  child: const Text(
                    'Пропустить',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                  ),
                ),
              ),
            ),
            // Страницы
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, index) =>
                    _OnboardingPageView(page: _pages[index]),
              ),
            ),
            // Индикаторы + кнопка
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _current == i ? 28 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _current == i
                              ? AppTheme.primary
                              : AppTheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _current == _pages.length - 1
                            ? 'Начать игру!'
                            : 'Далее',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Эмодзи-иллюстрация
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(0.1),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 3),
            ),
            child: Center(
              child: Text(page.emoji, style: const TextStyle(fontSize: 72)),
            ),
          ),
          const SizedBox(height: 32),
          // Заголовок
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Подзаголовок
          Text(
            page.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Элементы (3 типа решений)
          if (page.items != null)
            ...page.items!.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _DecisionCard(item: item),
              ),
            ),
          // Шаги (как это работает)
          if (page.showSteps)
            const _StepsWidget(),
        ],
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: item.color,
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsWidget extends StatelessWidget {
  const _StepsWidget();

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('1', 'Получай монеты', 'За задания и вход'),
      ('2', 'Планируй бюджет', 'Распредели по 3 направлениям'),
      ('3', 'Покупай и копи', 'Делай выбор каждый день'),
      ('4', 'Питомец растёт', 'Смотри на прогресс'),
    ];
    return Column(
      children: steps.map((s) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    s.$1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.$2,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      s.$3,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Модель данных для страницы онбординга.
class OnboardingPage {
  const OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.items,
    this.showSteps = false,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final List<OnboardingItem>? items;
  final bool showSteps;
}

class OnboardingItem {
  const OnboardingItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
  });

  final String icon;
  final String label;
  final String description;
  final Color color;
}
