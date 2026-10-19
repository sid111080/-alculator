import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/models/pet_character.dart';
import '../../core/models/player_profile.dart';
import '../../core/services/game_engine.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/task_service.dart';
import '../../data/content/math_tasks.dart';
import '../../widgets/fum.dart';

/// Раздел для взрослого (требование 8.12).
/// — Барьер: удержание кнопки 3 сек
/// — Цели приложения
/// — Пройденные темы
/// — Общий прогресс
/// — Сброс / удаление профиля
class AdultScreen extends StatefulWidget {
  const AdultScreen({super.key});

  @override
  State<AdultScreen> createState() => _AdultScreenState();
}

class _AdultScreenState extends State<AdultScreen> {
  bool _unlocked = false;
  double _holdProgress = 0;
  bool _isHolding = false;
  Timer? _holdTimer;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  // ─── Барьер: удержание 3 сек ───

  void _startHold() {
    _isHolding = true;
    _holdProgress = 0;
    _holdTimer = Timer.periodic(
      const Duration(milliseconds: 30),
      (timer) {
        setState(() {
          _holdProgress += 0.03;
          if (_holdProgress >= 1.0) {
            timer.cancel();
            _isHolding = false;
            _unlocked = true;
            _holdProgress = 0;
          }
        });
      },
    );
  }

  void _endHold() {
    if (!_isHolding) return;
    _isHolding = false;
    _holdTimer?.cancel();
    setState(() => _holdProgress = 0);
  }

  // ─── Сброс профиля ───

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Сбросить профиль?'),
        content: const Text(
          'Все игровые данные будут удалены: баланс, покупки, накопления, '
          'цель, прогресс питомца, завершённые задания.\n\n'
          'Это действие необратимо.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _resetProfile();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            child: const Text('Удалить всё'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetProfile() async {
    final storage = StorageService();
    await storage.resetProfile(_profile);
    await GameEngine().clearAll();
    await TaskService().clearAll();
    if (mounted) {
      context.go('/onboarding');
    }
  }

  PlayerProfile get _profile => StorageService().activeProfile ??
      PlayerProfile.create(playerName: 'Гость', character: PetCharacter.gapTooth);

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) return _buildBarrier();
    return _buildContent();
  }

  // ─── Барьер ───

  Widget _buildBarrier() {
    return Scaffold(
      appBar: AppBar(title: const Text('Для взрослого')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                'Раздел для взрослого',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Удерживайте кнопку 3 секунды',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),

              // Кнопка удержания
              GestureDetector(
                onLongPressStart: (_) => _startHold(),
                onLongPressEnd: (_) => _endHold(),
                onTapDown: (_) => _startHold(),
                onTapUp: (_) => _endHold(),
                onTapCancel: _endHold,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _holdProgress > 0
                        ? SweepGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.primary,
                            ],
                            endAngle: _holdProgress * 2 * math.pi,
                          )
                        : null,
                    color: AppTheme.surface,
                    border: Border.all(
                      color: _holdProgress > 0 ? AppTheme.primary : Colors.grey.shade300,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _holdProgress > 0
                              ? '${(_holdProgress * 100).toInt()}%'
                              : 'Удерживать',
                          style: TextStyle(
                            fontSize: _holdProgress > 0 ? 24 : 14,
                            fontWeight: FontWeight.w700,
                            color: _holdProgress > 0 ? AppTheme.primary : AppTheme.textSecondary,
                          ),
                        ),
                        if (_holdProgress > 0)
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: _holdProgress,
                              strokeWidth: 4,
                              backgroundColor: Colors.grey.shade200,
                              color: AppTheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Этот раздел видят только взрослые',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Контент ───

  Widget _buildContent() {
    final profile = _profile;
    final completedTasks = TaskService().completedIds();
    final totalTasks = TasksCatalog.all.length;
    final txs = GameEngine().allTransactions();
    final totalEarned = txs.where((t) => t.amount > 0).fold(0, (s, t) => s + t.amount);
    final totalSpent = txs.where((t) => t.amount < 0).fold(0, (s, t) => s - t.amount);

    // Пройденные темы
    final themes = TaskTheme.values.toList();
    final themesCompleted = themes
        .where((t) => TasksCatalog.byTheme(t).every((task) => completedTasks.contains(task.id)))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Раздел для взрослого'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _unlocked = false),
            icon: const Icon(Icons.lock_outline, size: 24),
            tooltip: 'Закрыть',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Цели приложения ───
            FumCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('🎯', 'Цели приложения'),
                  const SizedBox(height: 8),
                  _bullet('Научить ребёнка планировать расходы'),
                  _bullet('Различать обязательные и необязательные траты'),
                  _bullet('Копить на финансовую цель'),
                  _bullet('Оценивать свои финансовые решения'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ─── Пройденные темы ───
            FumCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('📚', 'Пройденные темы'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Тем завершено: $themesCompleted из ${themes.length}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: themes.length > 0 ? themesCompleted / themes.length : 0,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final theme in themes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            TasksCatalog.byTheme(theme).every((t) => completedTasks.contains(t.id))
                                ? '✅'
                                : '⬜',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              TasksCatalog.themeName(theme),
                              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                            ),
                          ),
                          Text(
                            '${TasksCatalog.byTheme(theme).where((t) => completedTasks.contains(t.id)).length} из ${TasksCatalog.byTheme(theme).length}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ─── Общий прогресс ───
            FumCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('📊', 'Общий прогресс'),
                  const SizedBox(height: 10),
                  _statRow('Игрок', profile.playerName),
                  _statRow('Питомец', '${profile.petName.isNotEmpty ? profile.petName : profile.character.displayName} (${PetCharacter.stageName(profile.petStage)})'),
                  _statRow('Период', '${profile.currentPeriod} / 5'),
                  _statRow('Очки роста', '${profile.growthScore}'),
                  _statRow('Баланс', '${profile.balance} 🪙'),
                  _statRow('Копилка', '${profile.savings} 🪙'),
                  _statRow('Всего заработано', '$totalEarned 🪙'),
                  _statRow('Всего потрачено', '$totalSpent 🪙'),
                  _statRow('Задания', '$completedTasks.length из $totalTasks'),
                  if (profile.goalName.isNotEmpty)
                    _statRow('Цель', profile.goalName),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ─── Состояние питомца ───
            FumCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('🐾', 'Состояние питомца'),
                  const SizedBox(height: 10),
                  _stateBar('Сытость', profile.petHunger, const Color(0xFFE85D5D)),
                  const SizedBox(height: 8),
                  _stateBar('Веселье', profile.petFun, AppTheme.accent),
                  const SizedBox(height: 8),
                  _stateBar('Чистота', profile.petCleanliness, const Color(0xFF4A90D9)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Опасная зона ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Опасная зона',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Сброс удалит все игровые данные. Действие необратимо.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _showResetDialog,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Сбросить профиль', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Text('•', style: TextStyle(fontSize: 13, color: AppTheme.primary)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary))),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _stateBar(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
