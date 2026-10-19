import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/theme.dart';
import '../../core/models/budget_plan.dart';
import '../../core/models/pet_character.dart';
import '../../core/models/player_profile.dart';
import '../../core/models/transaction.dart';
import '../../core/services/game_engine.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/task_service.dart';
import '../../data/content/glossary.dart';
import '../../data/content/math_tasks.dart';
import '../../data/content/savings_goals.dart';
import '../../widgets/fum.dart';

/// Экран прогресса и развития питомца (требование 8.10).
/// — Текущая стадия с SVG-аватаром (растёт вместе с питомцем)
/// — Очки роста и прогресс до следующей стадии
/// — Объяснение: от чего зависит рост
/// — История: завершённые задания, транзакции
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late PlayerProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = StorageService().activeProfile ??
        PlayerProfile.create(
          playerName: 'Гость',
          character: PetCharacter.gapTooth,
        );
  }

  @override
  Widget build(BuildContext context) {
    final char = _profile.character;
    final stage = _profile.petStage;
    final score = _profile.growthScore;

    // Прогресс до следующей стадии
    final (nextStageScore, nextStageLabel) = _nextStageInfo(stage);
    final progressToNext = nextStageScore > score
        ? ((score - _stageMinScore(stage)) / (nextStageScore - _stageMinScore(stage))).clamp(0.0, 1.0)
        : 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Прогресс')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Питомец + стадия ───
            FumCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      // Аватар по стадии (растёт!)
                      FumPetCircle(
                        svgAsset: char.svgAssetForStage(stage),
                        size: 100,
                        color: char.color,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profile.petName.isNotEmpty
                                  ? _profile.petName
                                  : char.displayName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: char.color,
                              ),
                            ),
                            const SizedBox(height: 6),
                            FumTag(
                              label:
                                  '${PetCharacter.stageEmoji(stage)} ${PetCharacter.stageName(stage)}',
                              color: char.color,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              PetCharacter.stageDescription(stage),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Очки роста
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Очки роста: $score',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (stage < 3)
                        Text(
                          'До ${PetCharacter.stageName(stage + 1)}: ещё ${_nextStageScore(stage) - score} очков',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      else
                        const FumTag(label: 'Максимальная стадия! 👑', color: AppTheme.accent),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Прогресс-бар до следующей стадии
                  if (stage < 3)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressToNext,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        color: char.color,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Как растёт питомец ───
            FumCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📈', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Как растёт питомец',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'За каждый период питомец получает до 3 очков, если:',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  _growthRule('🍎', 'Обязательные расходы покрыты (еда, уход)'),
                  _growthRule('💡', 'Необязательные траты в рамках плана'),
                  _growthRule('🏦', 'Копилка пополнена (думает о будущем)'),
                  const SizedBox(height: 8),
                  const Text(
                    '3–5 очков → Подросток. 6+ очков → Взрослый.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Стадии развития ───
            _buildStagesSection(char, stage),

            const SizedBox(height: 16),

            // ─── Прогресс по цели (8.11) ───
            _buildGoalProgress(),

            const SizedBox(height: 16),

            // ─── Итоги последнего периода (8.11) ───
            _buildLastPeriodSummary(),

            const SizedBox(height: 16),

            // ─── Завершённые задания ───
            _buildTasksSection(),

            const SizedBox(height: 16),

            // ─── История транзакций ───
            _buildHistorySection(),

            const SizedBox(height: 16),

            // ─── Справочник терминов (8.11) ───
            _buildGlossarySection(),
          ],
        ),
      ),
    );
  }

  // ─── Вспомогательные методы ───

  int _stageMinScore(int stage) => switch (stage) {
    1 => 0,
    2 => 3,
    3 => 6,
    _ => 0,
  };

  int _nextStageScore(int stage) => switch (stage) {
    1 => 3,
    2 => 6,
    _ => 6,
  };

  (int, String) _nextStageInfo(int stage) => switch (stage) {
    1 => (3, 'Подросток'),
    2 => (6, 'Взрослый'),
    _ => (6, 'Взрослый'),
  };

  Widget _growthRule(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Стадии ───

  Widget _buildStagesSection(PetCharacter char, int currentStage) {
    return FumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🐾', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Стадии развития',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int s = 1; s <= 3; s++)
                Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: char.color.withValues(alpha: s <= currentStage ? 0.12 : 0.04),
                        border: Border.all(
                          color: char.color.withValues(alpha: s <= currentStage ? 0.5 : 0.15),
                          width: s == currentStage ? 3 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          char.svgAssetForStage(s),
                          width: 56,
                          height: 56,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      PetCharacter.stageName(s),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: s == currentStage ? FontWeight.w700 : FontWeight.w400,
                        color: s == currentStage ? char.color : AppTheme.textSecondary,
                      ),
                    ),
                    if (s == currentStage)
                      const Text('← сейчас', style: TextStyle(fontSize: 10, color: AppTheme.primary)),
                    if (s > currentStage)
                      Text('$_stageMinScore(s)+ очк.', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Задания ───

  Widget _buildTasksSection() {
    final completed = TaskService().completedIds();
    final total = TasksCatalog.all.length;

    return FumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Задания',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$completed из $total',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? completed.length / total : 0,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          for (final task in TasksCatalog.all)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    completed.contains(task.id) ? '✅' : '⬜',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 13,
                        color: completed.contains(task.id)
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        decoration: completed.contains(task.id)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  Text(
                    TasksCatalog.themeName(task.theme),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─── История ───

  Widget _buildHistorySection() {
    final txs = GameEngine().recentTransactions(limit: 10);

    return FumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📜', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Последние операции',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (txs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Пока нет операций. Начни играть!',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
            )
          else
            for (final tx in txs)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      tx.source == TransactionSource.taskReward
                          ? '📋'
                          : tx.source == TransactionSource.purchase
                              ? '🛒'
                              : tx.source == TransactionSource.savingsDeposit
                                  ? '🐷'
                                  : tx.source == TransactionSource.savingsWithdraw
                                      ? '💸'
                                      : tx.source == TransactionSource.dailyBonus
                                          ? '🌅'
                                          : tx.source == TransactionSource.periodIncome
                                              ? '📅'
                                              : '💰',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tx.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${tx.amount > 0 ? '+' : ''}${tx.amount} 🪙',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tx.amount > 0 ? AppTheme.success : AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  // ─── Прогресс по цели (8.11) ───

  Widget _buildGoalProgress() {
    final goal = GoalsCatalog.findByName(_profile.goalName);
    if (goal == null) return const SizedBox.shrink();

    final progress = goal.cost > 0
        ? (_profile.savings / goal.cost).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (goal.cost - _profile.savings).clamp(0, goal.cost);
    final done = _profile.savings >= goal.cost;

    return FumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Прогресс по цели',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (done)
                const FumTag(label: 'Достигнута! 🎉', color: AppTheme.success),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(goal.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      goal.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: done ? AppTheme.success : AppTheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Накоплено: ${_profile.savings} 🪙',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                done
                    ? 'Цель достигнута! 🎉'
                    : 'Осталось: $remaining 🪙',
                style: TextStyle(
                  fontSize: 12,
                  color: done ? AppTheme.success : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Итоги последнего периода (8.11) ───

  Widget _buildLastPeriodSummary() {
    final plan = GameEngine().lastCompletedPlan;
    if (plan == null) {
      return FumCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Text('📊', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'Итоги периода',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            const Text(
              'Ещё не было',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return FumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Итоги периода ${plan.periodNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              FumTag(
                label: plan.verdict(),
                color: plan.verdict().contains('Отлично')
                    ? AppTheme.success
                    : AppTheme.accent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryRow('🍎 Обязательные', plan.requiredAmount, plan.requiredSpent, AppTheme.accent),
          const SizedBox(height: 6),
          _summaryRow('🎮 Необязательные', plan.optionalAmount, plan.optionalSpent, AppTheme.primary),
          const SizedBox(height: 6),
          _summaryRow('🏦 Копилка', plan.savingsAmount, plan.savingsDeposited, AppTheme.success),
          const SizedBox(height: 10),
          Text(
            plan.verdict(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, int planned, int actual, Color color) {
    final pct = planned > 0 ? (actual / planned).clamp(0.0, 1.5).toDouble() : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
            Text(
              '$actual / $planned 🪙',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            color: actual >= planned ? AppTheme.error : color,
          ),
        ),
      ],
    );
  }

  // ─── Справочник терминов (8.11) ───

  Widget _buildGlossarySection() {
    return FumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📖', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Словарь терминов',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Коротко о главном — нажми на термин, чтобы узнать больше',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          for (final entry in Glossary.all)
            _GlossaryTile(entry: entry),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
//  Плитка словаря с раскрытием
// ────────────────────────────────────────────────
class _GlossaryTile extends StatefulWidget {
  const _GlossaryTile({required this.entry});

  final GlossaryEntry entry;

  @override
  State<_GlossaryTile> createState() => _GlossaryTileState();
}

class _GlossaryTileState extends State<_GlossaryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _expanded
              ? AppTheme.primary.withValues(alpha: 0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _expanded
                ? AppTheme.primary.withValues(alpha: 0.3)
                : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.entry.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.entry.term,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(
                widget.entry.definition,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
