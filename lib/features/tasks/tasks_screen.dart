import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/models/player_profile.dart';
import '../../core/models/pet_character.dart';
import '../../core/services/game_engine.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/task_service.dart';
import '../../data/content/math_tasks.dart';
import '../../widgets/fum.dart';

/// Экран заданий (требование 8.8).
/// 6 заданий по 3 темам, игровая ситуация, ввод ответа,
/// объяснение после ответа, награда за верный ответ.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late PlayerProfile _profile;
  MathTask? _activeTask;
  late TextEditingController _answerController;
  bool _submitted = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _profile = StorageService().activeProfile ??
        PlayerProfile.create(
          playerName: 'Гость',
          character: PetCharacter.gapTooth,
        );
    _answerController = TextEditingController();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _openTask(MathTask task) {
    setState(() {
      _activeTask = task;
      _submitted = false;
      _isCorrect = false;
      _answerController.clear();
    });
  }

  void _backToList() {
    setState(() {
      _activeTask = null;
      _submitted = false;
      _answerController.clear();
    });
  }

  void _submitAnswer() {
    final answerText = _answerController.text.trim();
    if (answerText.isEmpty || _activeTask == null) return;

    final userAnswer = int.tryParse(answerText) ?? -1;
    final correct = userAnswer == _activeTask!.correctAnswer;

    setState(() {
      _submitted = true;
      _isCorrect = correct;
    });

    if (correct) {
      GameEngine().grantTaskReward(
        _profile,
        taskTitle: _activeTask!.title,
        reward: _activeTask!.reward,
      );
      TaskService().markCompleted(_activeTask!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_activeTask == null ? 'Задания' : _activeTask!.title),
        leading: _activeTask != null
            ? IconButton(
                onPressed: _backToList,
                icon: const Icon(Icons.arrow_back, size: 28),
              )
            : null,
      ),
      body: _activeTask == null ? _buildTaskList() : _buildTaskDetail(),
    );
  }

  // ─── Список заданий ───

  Widget _buildTaskList() {
    final tasks = TasksCatalog.all;
    final completedCount = TaskService().completedCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Прогресс
          FumCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text('📊', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Выполнено: $completedCount из ${tasks.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: tasks.isEmpty
                              ? 0.0
                              : completedCount / tasks.length,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Группы по темам
          for (final theme in TaskTheme.values) ...[
            _buildThemeSection(theme),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeSection(TaskTheme theme) {
    final tasks = TasksCatalog.byTheme(theme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _themeEmoji(theme),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              TasksCatalog.themeName(theme),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final task in tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TaskListItem(
              task: task,
              completed: TaskService().isCompleted(task.id),
              onTap: () => _openTask(task),
            ),
          ),
      ],
    );
  }

  String _themeEmoji(TaskTheme theme) => switch (theme) {
    TaskTheme.budget => '📋',
    TaskTheme.savings => '🐷',
    TaskTheme.payments => '🛒',
  };

  // ─── Детали задания ───

  Widget _buildTaskDetail() {
    final task = _activeTask!;
    final isCompleted = TaskService().isCompleted(task.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Эмодзи + тема
          Center(
            child: Text(task.emoji, style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 8),
          Center(
            child: FumTag(
              label: TasksCatalog.themeName(task.theme),
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Ситуация
          FumCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ситуация',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  task.situation,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Вопрос
          FumCard(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primary.withValues(alpha: 0.06),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('❓', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    task.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Поле ввода или результат
          if (!_submitted) ...[
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Введи ответ…',
                hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                prefixIcon: const Icon(Icons.calculate_outlined, size: 28),
                suffixText: '🪙',
                suffixStyle: const TextStyle(fontSize: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _submitAnswer,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.buttonRadius,
                  ),
                ),
                child: const Text('Проверить'),
              ),
            ),
          ] else ...[
            // Результат
            _buildResult(task),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Результат ───

  Widget _buildResult(MathTask task) {
    if (_isCorrect) {
      return Column(
        children: [
          // Успех
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.success.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  'Верно! Молодец!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+${task.reward} 🪙 на баланс',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Объяснение
          FumCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'Пояснение',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.explanation,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Кнопка «К заданиям»
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _backToList,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.buttonRadius,
                ),
              ),
              child: const Text('К заданиям', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          // Неправильно — без паники
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accent.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Text('🤔', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  'Пока не совсем так',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Правильный ответ: ${task.correctAnswer} 🪙',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Объяснение
          FumCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'Пояснение',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.explanation,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Повторить или к списку
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      _answerController.clear();
                      setState(() => _submitted = false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.buttonRadius,
                      ),
                    ),
                    child: const Text('Ещё раз', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _backToList,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.buttonRadius,
                      ),
                    ),
                    child: const Text('Далее', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}

// ────────────────────────────────────────────────
//  Элемент списка заданий
// ────────────────────────────────────────────────
class _TaskListItem extends StatelessWidget {
  const _TaskListItem({
    required this.task,
    required this.completed,
    required this.onTap,
  });

  final MathTask task;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: completed
              ? Colors.grey.shade100
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: completed
                ? Colors.grey.shade300
                : AppTheme.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              completed ? '✅' : task.emoji,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: completed
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      decoration:
                          completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    completed
                        ? 'Выполнено'
                        : 'Награда: +${task.reward} 🪙',
                    style: TextStyle(
                      fontSize: 12,
                      color: completed
                          ? AppTheme.textSecondary
                          : AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (!completed)
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
