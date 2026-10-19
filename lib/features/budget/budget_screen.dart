import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/models/budget_plan.dart';
import '../../core/models/pet_character.dart';
import '../../core/models/player_profile.dart';
import '../../core/services/game_engine.dart';
import '../../core/services/storage_service.dart';
import '../../widgets/feedback_card.dart';

/// Экран планирования бюджета (требование 8.5).
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

// Локальные константы для скруглений и цветов
const double _rLg = 16;
const double _rMd = 12;
const double _rSm = 8;
final Color _surfaceVariant = Colors.grey.shade100;

class _BudgetScreenState extends State<BudgetScreen> {
  late PlayerProfile _profile;
  BudgetPlan? _plan;

  int _required = 0;
  int _optional = 0;
  int _savings = 0;

  /// Результат оценки периода (8.10).
  FeedbackCard? _periodResult;

  @override
  void initState() {
    super.initState();
    _profile = StorageService().activeProfile ??
        PlayerProfile.create(
          playerName: 'Гость',
          character: PetCharacter.gapTooth,
        );
    final existingPlan = GameEngine().currentBudgetPlan;
    if (existingPlan != null) {
      _plan = existingPlan;
      _required = existingPlan.requiredAmount;
      _optional = existingPlan.optionalAmount;
      _savings = existingPlan.savingsAmount;
    } else {
      final b = (_profile.balance).clamp(30, 999);
      _required = (b * 0.5) ~/ 1;
      _optional = (b * 0.2) ~/ 1;
      _savings = (b * 0.3) ~/ 1;
    }
  }

  int get _budget => (_profile.balance + (_plan?.totalAllocated ?? 0)).clamp(30, 999);
  int get _allocated => _required + _optional + _savings;
  int get _remaining => _budget - _allocated;

  bool get _isConfirmed => _plan != null && _plan!.confirmed;
  bool get _canConfirm =>
      _required > 0 && _optional > 0 && _savings > 0 && _remaining >= 0;

  void _confirmPlan() {
    final plan = BudgetPlan(
      periodNumber: (_plan?.periodNumber ?? 1) + 1,
      requiredAmount: _required,
      optionalAmount: _optional,
      savingsAmount: _savings,
      confirmed: true,
    );

    if (_savings > 0 && GameEngine().depositToSavings(_profile, amount: _savings)) {
      plan.recordSavingsDeposit(_savings);
    }

    GameEngine().setBudgetPlan(plan);
    setState(() => _plan = plan);
  }

  void _adjust(int which, int delta) {
    final newAllocated = _allocated + delta;
    if (newAllocated > _budget || newAllocated < 0) return;

    switch (which) {
      case 0:
        if (_required + delta >= 0) setState(() => _required += delta);
      case 1:
        if (_optional + delta >= 0) setState(() => _optional += delta);
      case 2:
        if (_savings + delta >= 0) setState(() => _savings += delta);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('План бюджета')),
      body: _periodResult != null
          ? _buildPeriodResult()
          : _isConfirmed
              ? _buildComparison()
              : _buildPlanner(),
    );
  }

  /// Экран результата периода (8.10) — после «Начать новый период».
  Widget _buildPeriodResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _periodResult!,
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => setState(() => _periodResult = null),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('К планированию', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Планирование (до подтверждения) ───

  Widget _buildPlanner() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Распределение средств', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('Доступно: $_budget 🪙. Раздели по трём направлениям.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),

          _directionCard('🍎', 'Обязательные расходы', 'Еда и уход за питомцем', _required, AppTheme.accent, () => _adjust(0, -5), () => _adjust(0, 5)),
          const SizedBox(height: 12),
          _directionCard('🎮', 'Необязательные расходы', 'Игрушки и развлечения', _optional, AppTheme.primary, () => _adjust(1, -5), () => _adjust(1, 5)),
          const SizedBox(height: 12),
          _directionCard('🏦', 'Накопления (копилка)', 'Копим на цель', _savings, AppTheme.success, () => _adjust(2, -5), () => _adjust(2, 5)),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(_rSm),
            child: LinearProgressIndicator(
              value: _budget > 0 ? (_allocated / _budget).clamp(0.0, 1.0) : 0,
              minHeight: 12,
              backgroundColor: _surfaceVariant,
              color: _remaining < 0 ? AppTheme.error : AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Распределено: $_allocated / $_budget', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              Text(
                _remaining >= 0 ? 'Осталось: $_remaining 🪙' : 'Не хватает: ${-_remaining} 🪙',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _remaining < 0 ? AppTheme.error : AppTheme.success),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _canConfirm ? _confirmPlan : null,
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              child: Text('Подтвердить план', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ),

          if (!_canConfirm) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                _required == 0 || _optional == 0 || _savings == 0 ? 'Заполни все три направления' : 'Сумма превышает бюджет',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _directionCard(String icon, String title, String subtitle, int amount, Color color, VoidCallback onMinus, VoidCallback onPlus) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(_rLg), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ])),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _stepBtn('−', onMinus),
            Container(width: 72, alignment: Alignment.center, child: Text('$amount 🪙', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
            _stepBtn('+', onPlus),
          ]),
        ],
      ),
    );
  }

  Widget _stepBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 48, height: 48, decoration: BoxDecoration(color: _surfaceVariant, borderRadius: BorderRadius.circular(_rSm)), alignment: Alignment.center, child: Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
    );
  }

  // ─── Сравнение план / факт (после подтверждения) ───

  Widget _buildComparison() {
    final plan = _plan!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Период ${plan.periodNumber}: план vs факт', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),

          _comparisonRow('🍎 Обязательные', plan.requiredAmount, plan.requiredSpent, AppTheme.accent),
          const SizedBox(height: 8),
          _comparisonRow('🎮 Необязательные', plan.optionalAmount, plan.optionalSpent, AppTheme.primary),
          const SizedBox(height: 8),
          _comparisonRow('🏦 Копилка', plan.savingsAmount, plan.savingsDeposited, AppTheme.success),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(_rLg), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plan.verdict(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text('Обязательные покрыты на ${(plan.requiredUsage * 100).toInt()}%, копилка пополнена на ${(plan.savingsUsage * 100).toInt()}.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ]),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () {
                final (earned, reasons, stageChanged) =
                    GameEngine().startNewPeriod(_profile);
                setState(() {
                  _plan = null;
                  _periodResult = FeedbackCard(
                    type: stageChanged ? FeedbackType.success : FeedbackType.info,
                    title: stageChanged
                        ? '🎉 Новый период! Питомец вырос!'
                        : 'Новый период начат',
                    changedItems: [
                      'Очки роста: +$earned (всего: ${_profile.growthScore})',
                      if (stageChanged)
                        'Стадия: ${PetCharacter.stageName(_profile.petStage)}',
                    ],
                    explanation: reasons.join(' '),
                    nextStep: 'Планируй новый бюджет — и питомец продолжит расти!',
                  );
                });
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              icon: const Icon(Icons.refresh),
              label: Text('Начать новый период', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonRow(String title, int planned, int actual, Color color) {
    final pct = planned > 0 ? (actual / planned).clamp(0.0, 1.5).toDouble() : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(_rMd), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          Text('$actual / $planned 🪙', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(_rSm),
          child: LinearProgressIndicator(value: pct.clamp(0.0, 1.0).toDouble(), minHeight: 8, backgroundColor: _surfaceVariant, color: actual >= planned ? AppTheme.error : color),
        ),
      ]),
    );
  }
}
