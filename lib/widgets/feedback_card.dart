import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Тип обратной связи.
enum FeedbackType { success, warning, info }

/// Переиспользуемый виджет обратной связи (требование 8.9).
/// Показывает: что изменилось, почему, следующий шаг.
/// При неудаче — путь восстановления.
class FeedbackCard extends StatelessWidget {
  const FeedbackCard({
    super.key,
    required this.type,
    this.title,
    this.changedItems = const [],
    this.explanation,
    this.nextStep,
    this.actions = const [],
  });

  final FeedbackType type;

  /// Заголовок (например «Покупка успешна!» или «Не хватает средств»).
  final String? title;

  /// Что изменилось: список строк вида «Баланс: −30 🪙», «Сытость: +10».
  final List<String> changedItems;

  /// Почему так произошло (причинно-следственная связь простыми словами).
  final String? explanation;

  /// Что делать дальше (следующий шаг).
  final String? nextStep;

  /// Кнопки действий (например «Ещё раз», «К заданиям»).
  final List<FeedbackAction> actions;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (type) {
      FeedbackType.success => (AppTheme.success, '🎉'),
      FeedbackType.warning => (AppTheme.accent, '⚠️'),
      FeedbackType.info => (const Color(0xFF4A90D9), '💡'),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка + заголовок
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title ??
                      switch (type) {
                        FeedbackType.success => 'Готово!',
                        FeedbackType.warning => 'Обрати внимание',
                        FeedbackType.info => 'Подсказка',
                      },
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          // Что изменилось
          if (changedItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  for (final item in changedItems)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Text('•', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Почему (объяснение)
          if (explanation != null && explanation!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💬', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    explanation!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Следующий шаг
          if (nextStep != null && nextStep!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('→', style: TextStyle(fontSize: 16, color: AppTheme.primary)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    nextStep!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Кнопки действий
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: actions[i].onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: actions[i].primary
                              ? AppTheme.primary
                              : AppTheme.surface,
                          foregroundColor: actions[i].primary
                              ? Colors.white
                              : AppTheme.textPrimary,
                          side: actions[i].primary
                              ? null
                              : const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          actions[i].label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Кнопка действия внутри FeedbackCard.
class FeedbackAction {
  const FeedbackAction({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;
}
