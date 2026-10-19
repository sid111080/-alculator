import 'package:hive/hive.dart';

part 'budget_plan.g.dart';

/// План бюджета на игровой период (требование 8.5).
@HiveType(typeId: 4)
class BudgetPlan extends HiveObject {
  /// Номер периода (1, 2, 3…).
  @HiveField(0)
  int periodNumber;

  /// Сумма на обязательные расходы.
  @HiveField(1)
  int requiredAmount;

  /// Сумма на необязательные расходы.
  @HiveField(2)
  int optionalAmount;

  /// Сумма в накопления (копилку).
  @HiveField(3)
  int savingsAmount;

  /// Подтверждён ли план (после подтверждения изменить нельзя).
  @HiveField(4)
  bool confirmed;

  // ─── Факт за период ───

  /// Реально потрачено на обязательные.
  @HiveField(5)
  int requiredSpent;

  /// Реально потрачено на необязательные.
  @HiveField(6)
  int optionalSpent;

  /// Реально переведено в копилку.
  @HiveField(7)
  int savingsDeposited;

  BudgetPlan({
    required this.periodNumber,
    this.requiredAmount = 0,
    this.optionalAmount = 0,
    this.savingsAmount = 0,
    this.confirmed = false,
    this.requiredSpent = 0,
    this.optionalSpent = 0,
    this.savingsDeposited = 0,
  });

  /// Общее распределённое.
  int get totalAllocated => requiredAmount + optionalAmount + savingsAmount;

  /// Остаток (бюджет − распределённое).
  int remainingFor(int budget) => budget - totalAllocated;

  /// Все ли 3 направления заполнены.
  bool get allDirectionsFilled =>
      requiredAmount > 0 && optionalAmount > 0 && savingsAmount > 0;

  /// Можно ли подтвердить (все направления > 0 и сумма ≤ бюджет).
  bool canConfirm(int budget) => allDirectionsFilled && totalAllocated <= budget;

  // ─── Факт: учёт расходов ───

  void recordRequiredSpend(int amount) {
    requiredSpent += amount;
  }

  void recordOptionalSpend(int amount) {
    optionalSpent += amount;
  }

  void recordSavingsDeposit(int amount) {
    savingsDeposited += amount;
  }

  // ─── Сравнение план/факт ───

  /// Процент использования обязательных (100 = точно по плану).
  double get requiredUsage => requiredAmount > 0 ? requiredSpent / requiredAmount : 0;
  double get optionalUsage => optionalAmount > 0 ? optionalSpent / optionalAmount : 0;
  double get savingsUsage => savingsAmount > 0 ? savingsDeposited / savingsAmount : 0;

  /// Краткий вердикт для ребёнка.
  String verdict() {
    if (!confirmed) return 'План ещё не подтверждён';
    final reqOk = requiredSpent >= requiredAmount * 0.9;
    final savOk = savingsDeposited >= savingsAmount * 0.5;
    if (reqOk && savOk) return 'Отличный период! 🌟';
    if (!reqOk) return 'Не хватило на обязательные — в следующий раз запланируй больше 🍎';
    return 'Хорошо, но можно копить активнее 🏦';
  }
}
