import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/models/pet_character.dart';
import '../../core/models/player_profile.dart';
import '../../core/services/game_engine.dart';
import '../../core/services/storage_service.dart';
import '../../data/content/savings_goals.dart';
import '../../widgets/feedback_card.dart';

/// Экран накоплений и финансовой цели (требование 8.7).
/// Выбор цели, прогресс, пополнение, снятие с подтверждением, расчёт срока.
class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  late PlayerProfile _profile;
  final List<SavingsGoal> _goals = [];
  bool _showGoalPicker = false;

  /// Последнее действие — для показа FeedbackCard (8.9).
  FeedbackCard? _lastFeedback;

  @override
  void initState() {
    super.initState();
    _profile = StorageService().activeProfile ??
        PlayerProfile.create(
          playerName: 'Гость',
          character: PetCharacter.gapTooth,
        );
    _goals.addAll(GoalsCatalog.forCharacter(_profile.character));
    // Если цель не выбрана ИЛИ не найдена в каталоге — показываем выбор
    if (_currentGoal == null) _showGoalPicker = true;
  }

  SavingsGoal? get _currentGoal => GoalsCatalog.findByName(_profile.goalName);

  double get _progress => _currentGoal != null && _currentGoal!.cost > 0
      ? (_profile.savings / _currentGoal!.cost).clamp(0.0, 1.0)
      : 0.0;

  int get _remaining => (_currentGoal?.cost ?? 0) - _profile.savings;

  /// Простой расчёт срока: остаток / среднее пополнение за период.
  String get _etaText {
    if (_currentGoal == null) return '';
    if (_profile.savings >= _currentGoal!.cost) return 'Цель достигнута! 🎉';
    // Средняя сумма пополнения — берём план бюджета (если есть)
    final plan = GameEngine().currentBudgetPlan;
    final avgDeposit = plan?.savingsAmount ?? 30;
    if (avgDeposit <= 0) return 'Начни пополнять копилку';
    final periodsLeft = (_remaining / avgDeposit).ceil();
    if (periodsLeft <= 1) return 'Ещё 1 период!';
    return '≈ $periodsLeft период(ов) по ${avgDeposit} 🪙/период';
  }

  void _selectGoal(SavingsGoal goal) {
    _profile.goalName = goal.name;
    _profile.goalTarget = goal.cost;
    StorageService().saveProfile(_profile);
    setState(() => _showGoalPicker = false);
  }

  void _deposit(int amount) {
    final savingsBefore = _profile.savings;
    final ok = GameEngine().depositToSavings(_profile, amount: amount);
    if (ok && mounted) {
      setState(() {
        _lastFeedback = FeedbackCard(
          type: FeedbackType.success,
          title: 'Копилка пополнена!',
          changedItems: [
            'Баланс: −$amount 🪙 (осталось ${_profile.balance})',
            'Копилка: +$amount 🪙 (стало ${_profile.savings})',
            if (_currentGoal != null)
              'Прогресс цели: ${(_progress * 100).toInt()}%',
          ],
          explanation:
              'Ты отложил часть дохода — это и есть сбережения. '
              'Регулярные взносы помогают быстрее достичь цели.',
          nextStep:
              _profile.savings >= (_currentGoal?.cost ?? 0)
                  ? 'Цель достигнута! 🎉 Ты можешь снять средства на покупку'
                  : 'Осталось ${(_currentGoal?.cost ?? 0) - _profile.savings} 🪙 до цели. '
                        'Пополняй копилку каждый период!',
        );
      });
    }
  }

  void _showWithdrawDialog(int amount) {
    final newSavings = _profile.savings - amount;
    final newProgressPct = _currentGoal != null && _currentGoal!.cost > 0
        ? newSavings * 100 ~/ _currentGoal!.cost
        : 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Снять с копилки?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сумма к снятию: $amount 🪙', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'После снятия: ${newSavings} 🪙 в копилке',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            if (_currentGoal != null) ...[
              const SizedBox(height: 8),
              Text(
                'Прогресс цели снизится до $newProgressPct%',
                style: TextStyle(fontSize: 13, color: AppTheme.accent),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              GameEngine().withdrawFromSavings(_profile, amount: amount);
              Navigator.pop(ctx);
              if (mounted) {
                setState(() {
                  _lastFeedback = FeedbackCard(
                    type: FeedbackType.warning,
                    title: 'Средства сняты с копилки',
                    changedItems: [
                      'Копилка: −$amount 🪙 (осталось ${_profile.savings})',
                      'Баланс: +$amount 🪙 (стало ${_profile.balance})',
                      if (_currentGoal != null)
                        'Прогресс цели: ${(_progress * 100).toInt()}%',
                    ],
                    explanation:
                        'Снятие уменьшает накопления. Если цель ещё не достигнута, '
                        'будет нужно больше времени, чтобы её достичь.',
                    nextStep:
                        _profile.savings > 0
                            ? 'Копилка не пуста — можно пополнить её снова'
                            : 'Копилка пуста. Начни пополнять её, чтобы вернуться к цели',
                  );
                });
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accent, foregroundColor: Colors.white),
            child: const Text('Снять'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Копилка')),
      body: _showGoalPicker ? _buildGoalPicker() : _buildSavings(),
    );
  }

  // ─── Выбор цели ───

  Widget _buildGoalPicker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Выбери цель для копилки', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('На что будем копить?', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),

          for (final goal in _goals)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _selectGoal(goal),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: Text(goal.emoji, style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                            const SizedBox(height: 2),
                            Text(goal.description, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${goal.cost} 🪙', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                          const SizedBox(height: 4),
                          const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Основной экран накоплений ───

  Widget _buildSavings() {
    final goal = _currentGoal!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FeedbackCard после действия (8.9)
          if (_lastFeedback != null) ...[
            _lastFeedback!,
            const SizedBox(height: 16),
          ],

          // Текущая цель
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(goal.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                          Text(goal.description, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _showGoalPicker = true),
                      icon: const Icon(Icons.swap_horiz, size: 20),
                      tooltip: 'Сменить цель',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Прогресс
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Накоплено: ${_profile.savings} 🪙', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    Text('Цель: ${goal.cost} 🪙', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 14,
                    backgroundColor: Colors.grey.shade200,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(_progress * 100).toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    if (_remaining > 0)
                      Text('Осталось: $_remaining 🪙', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_etaText, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Баланс
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Баланс: ${_profile.balance} 🪙', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text('Копилка: ${_profile.savings} 🪙', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Пополнение
          Text('Пополнить копилку', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          Row(
            children: [
              _depositBtn(10),
              const SizedBox(width: 8),
              _depositBtn(20),
              const SizedBox(width: 8),
              _depositBtn(50),
              const SizedBox(width: 8),
              Expanded(child: _depositBtn('Всё')),
            ],
          ),

          if (_profile.savings > 0) ...[
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),

            // Снятие
            Text('Снять с копилки', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('Снятие уменьшит прогресс цели', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 10),
            Row(
              children: [
                _withdrawBtn(10),
                const SizedBox(width: 8),
                _withdrawBtn(20),
                const SizedBox(width: 8),
                Expanded(child: _withdrawBtn('Всё')),
              ],
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _depositBtn(dynamic amount) {
    final isAll = amount is String;
    final realAmount = isAll ? _profile.balance : (amount as int);
    final canAfford = realAmount > 0 && _profile.balance >= realAmount;
    return Expanded(
      child: GestureDetector(
        onTap: canAfford ? () => _deposit(realAmount) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: canAfford ? AppTheme.primary : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            isAll ? 'Всё' : '+$amount',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: canAfford ? Colors.white : AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _withdrawBtn(dynamic amount) {
    final isAll = amount is String;
    final realAmount = isAll ? _profile.savings : (amount as int);
    final canWithdraw = realAmount > 0 && _profile.savings >= realAmount;
    return Expanded(
      child: GestureDetector(
        onTap: canWithdraw ? () => _showWithdrawDialog(realAmount) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: canWithdraw ? AppTheme.accent.withValues(alpha: 0.15) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: canWithdraw ? AppTheme.accent.withValues(alpha: 0.4) : Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            isAll ? 'Всё' : '−$amount',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: canWithdraw ? AppTheme.accent : AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}
