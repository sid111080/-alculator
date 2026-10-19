/// Тема задания.
enum TaskTheme { budget, savings, payments }

/// Математическое задание — игровая ситуация с числовым ответом.
class MathTask {
  final String id;
  final TaskTheme theme;
  final String emoji;
  final String title;
  final String situation;
  final String question;
  final int correctAnswer;
  final String explanation;
  final int reward;

  const MathTask({
    required this.id,
    required this.theme,
    required this.emoji,
    required this.title,
    required this.situation,
    required this.question,
    required this.correctAnswer,
    required this.explanation,
    required this.reward,
  });
}

/// Каталог заданий — 6 шт. (по 2 на каждую тему).
/// Новое задание добавляется без переработки основной логики (требование 8.14).
class TasksCatalog {
  static final List<MathTask> all = [
    // ─── Тема 1: Планирование бюджета ───
    MathTask(
      id: 't1',
      theme: TaskTheme.budget,
      emoji: '📋',
      title: 'План на период',
      situation:
          'У тебя 100 🪙 за этот период. Корм для питомца стоит 40 🪙, '
          'а игрушка — 25 🪙. Ты хочешь отложить часть в копилку.',
      question: 'Сколько 🪙 останется на копилку, если купить корм и игрушку?',
      correctAnswer: 35,
      explanation:
          '100 − 40 (корм) − 25 (игрушка) = 35 🪙. '
          'Всегда сначала покрывай обязательные расходы, потом желаемые — '
          'и то, что осталось, можно отложить.',
      reward: 20,
    ),
    MathTask(
      id: 't2',
      theme: TaskTheme.budget,
      emoji: '🧮',
      title: 'Сколько всего?',
      situation:
          'Ты составляешь план: обязательные расходы — 50 🪙, '
          'необязательные — 30 🪙, копилка — 20 🪙.',
      question: 'Сколько всего 🪙 ты планируешь распределить?',
      correctAnswer: 100,
      explanation:
          '50 + 30 + 20 = 100 🪙. План бюджета — это распределение ВСЕЙ '
          'суммы по направлениям. Если сумма плана больше дохода — '
          'нужно что-то сократить.',
      reward: 20,
    ),

    // ─── Тема 2: Сбережения ───
    MathTask(
      id: 't3',
      theme: TaskTheme.savings,
      emoji: '🐷',
      title: 'Копим на цель',
      situation:
          'Ты копишь на новую игрушку за 100 🪙. '
          'За первый период отложила 20 🪙, за второй — 30 🪙.',
      question: 'Сколько 🪙 ещё нужно накопить, чтобы купить игрушку?',
      correctAnswer: 50,
      explanation:
          '100 − 20 − 30 = 50 🪙 осталось. Регулярные небольшие взносы '
          'помогают быстрее достичь цели, чем одна большая сумма.',
      reward: 20,
    ),
    MathTask(
      id: 't4',
      theme: TaskTheme.savings,
      emoji: '🎯',
      title: 'Почти готово!',
      situation:
          'У тебя в копилке 60 🪙. Ты хочешь накопить 90 🪙 '
          'на билеты в парк развлечений.',
      question: 'Сколько 🪙 нужно отложить, чтобы в копилке стало 90?',
      correctAnswer: 30,
      explanation:
          '90 − 60 = 30 🪙. Когда до цели совсем немного — '
          'ещё пара периодов регулярных взносов и покупка твоя!',
      reward: 20,
    ),

    // ─── Тема 3: Платежи и покупки ───
    MathTask(
      id: 't5',
      theme: TaskTheme.payments,
      emoji: '🛒',
      title: 'Покупка корма',
      situation:
          'Питомец проголодался! Корм стоит 30 🪙, а у тебя на балансе 80 🪙.',
      question: 'Сколько 🪙 останется после покупки корма?',
      correctAnswer: 50,
      explanation:
          '80 − 30 = 50 🪙. Обязательные расходы — это то, без чего '
          'питомец не обойдётся. Покупай их в первую очередь.',
      reward: 20,
    ),
    MathTask(
      id: 't6',
      theme: TaskTheme.payments,
      emoji: '🍬',
      title: 'Считаем сладости',
      situation:
          'Ты хочешь угостить питомца 3 конфетами. '
          'Каждая конфета стоит 10 🪙.',
      question: 'Сколько 🪙 ты заплатишь за все 3 конфеты?',
      correctAnswer: 30,
      explanation:
          '3 × 10 = 30 🪙. Умножение помогает быстро посчитать '
          'сумму за несколько одинаковых покупок.',
      reward: 20,
    ),
  ];

  /// Задания по теме.
  static List<MathTask> byTheme(TaskTheme theme) =>
      all.where((t) => t.theme == theme).toList();

  /// Найти задание по id.
  static MathTask? findById(String id) =>
      all.where((t) => t.id == id).firstOrNull;

  /// Название темы (для отображения).
  static String themeName(TaskTheme theme) => switch (theme) {
        TaskTheme.budget => 'Планирование бюджета',
        TaskTheme.savings => 'Сбережения',
        TaskTheme.payments => 'Платежи и покупки',
      };
}
