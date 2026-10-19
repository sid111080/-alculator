import 'package:hive/hive.dart';
import '../models/budget_plan.dart';
import '../models/pet_character.dart';
import '../models/player_profile.dart';
import '../models/transaction.dart';
import 'storage_service.dart';

/// Центральный сервис игровой экономики.
/// Все изменения баланса проходят через этот класс —
/// баланс не меняется без объяснения (требование 8.4).
class GameEngine {
  GameEngine._();
  static final GameEngine _instance = GameEngine._();
  factory GameEngine() => _instance;

  late Box<Transaction> _txBox;
  BudgetPlan? _budgetPlan;

  /// Последний завершённый план (для экрана прогресса, требование 8.11).
  BudgetPlan? _lastCompletedPlan;

  static const String _txBoxName = 'transactions';

  /// Размер ежедневного бонуса за вход.
  static const int dailyBonusAmount = 10;

  /// Награда за выполнение задания (по умолчанию).
  static const int defaultTaskReward = 20;

  Future<void> init() async {
    _txBox = await Hive.openBox<Transaction>(_txBoxName);
  }

  // ─── Доход ───

  /// Ежедневный бонус за вход.
  /// Возвращает true, если бонус начислен (не был уже сегодня).
  Future<bool> grantDailyBonus(PlayerProfile profile) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // Проверка: был ли уже бонус сегодня
    final hasBonusToday = _txBox.values.any(
      (tx) =>
          tx.source == TransactionSource.dailyBonus &&
          tx.timestamp.isAfter(todayStart),
    );
    if (hasBonusToday) return false;

    final tx = Transaction.create(
      amount: dailyBonusAmount,
      source: TransactionSource.dailyBonus,
      description: 'Бонус за вход: +$dailyBonusAmount 🪙',
    );
    await _txBox.put(tx.id, tx);

    profile.balance += dailyBonusAmount;
    await StorageService().saveProfile(profile);
    return true;
  }

  /// Награда за выполнение задания.
  void grantTaskReward(
    PlayerProfile profile, {
    required String taskTitle,
    int? reward,
  }) {
    final amount = reward ?? defaultTaskReward;
    final tx = Transaction.create(
      amount: amount,
      source: TransactionSource.taskReward,
      description: 'Задание «$taskTitle»: +$amount 🪙',
    );
    _txBox.put(tx.id, tx);

    profile.balance += amount;
    profile.activeTaskCompleted = true;
    StorageService().saveProfile(profile);
  }

  /// Периодический доход (начисление за новый период).
  void grantPeriodIncome(PlayerProfile profile, {int amount = 50}) {
    final tx = Transaction.create(
      amount: amount,
      source: TransactionSource.periodIncome,
      description: 'Доход за период: +$amount 🪙',
    );
    _txBox.put(tx.id, tx);

    profile.balance += amount;
    StorageService().saveProfile(profile);
  }

  // ─── Расход ───

  /// Покупка. Возвращает true при успехе, false при нехватке средств.
  /// [effectOnPet] — строка вида «Сытость +10» — применяется к питомцу (8.9).
  bool purchase(
    PlayerProfile profile, {
    required String itemName,
    required int price,
    required bool isRequired,
    String effectOnPet = '',
  }) {
    if (profile.balance < price) return false;

    final tx = Transaction.create(
      amount: -price,
      source: TransactionSource.purchase,
      description:
          'Покупка «$itemName» (${isRequired ? 'обязательная' : 'необязательная'}): −$price 🪙',
    );
    _txBox.put(tx.id, tx);

    profile.balance -= price;

    // Влияние на питомца (8.9: последствие каждого действия)
    _applyPetEffect(profile, effectOnPet);

    // Обновляем факт плана бюджета (8.5)
    final plan = _budgetPlan;
    if (plan != null && plan.confirmed) {
      if (isRequired) {
        plan.recordRequiredSpend(price);
      } else {
        plan.recordOptionalSpend(price);
      }
    }

    StorageService().saveProfile(profile);
    return true;
  }

  /// Применяет строку вида «Сытость +10» / «Веселье +20» / «Чистота +10»
  /// / «Настроение +15» к состоянию питомца (обратимо, в пределах 0–100).
  void _applyPetEffect(PlayerProfile profile, String effect) {
    final match = RegExp(r'(\w+)\s*([+-]\d+)').firstMatch(effect);
    if (match == null) return;
    final stat = match.group(1);
    final amount = int.tryParse(match.group(2)!) ?? 0;
    switch (stat) {
      case 'Сытость':
        profile.petHunger = (profile.petHunger + amount).clamp(0, 100);
      case 'Веселье':
      case 'Настроение':
        profile.petFun = (profile.petFun + amount).clamp(0, 100);
      case 'Чистота':
        profile.petCleanliness = (profile.petCleanliness + amount).clamp(0, 100);
    }
  }

  /// Пополнение накоплений.
  bool depositToSavings(PlayerProfile profile, {required int amount}) {
    if (amount <= 0 || profile.balance < amount) return false;

    final tx = Transaction.create(
      amount: -amount,
      source: TransactionSource.savingsDeposit,
      description: 'Перевод в копилку: −$amount 🪙',
    );
    _txBox.put(tx.id, tx);

    profile.balance -= amount;

    // Обновляем факт плана бюджета (8.5)
    final plan = _budgetPlan;
    if (plan != null && plan.confirmed) {
      plan.recordSavingsDeposit(amount);
    }
    profile.savings += amount;
    StorageService().saveProfile(profile);
    return true;
  }

  /// Снятие с накоплений.
  bool withdrawFromSavings(PlayerProfile profile, {required int amount}) {
    if (amount <= 0 || profile.savings < amount) return false;

    final tx = Transaction.create(
      amount: amount,
      source: TransactionSource.savingsWithdraw,
      description: 'Снятие из копилки: +$amount 🪙',
    );
    _txBox.put(tx.id, tx);

    profile.savings -= amount;
    profile.balance += amount;
    StorageService().saveProfile(profile);
    return true;
  }

  // ─── История ───

  /// Последние N транзакций (новые сверху).
  List<Transaction> recentTransactions({int limit = 20}) {
    final all = _txBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all.length > limit ? all.sublist(0, limit) : all;
  }

  /// Все транзакции профиля (для истории в разделе прогресса).
  List<Transaction> allTransactions() {
    final all = _txBox.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return all;
  }

  // ─── План бюджета (требование 8.5) ───

  /// Текущий план бюджета (или null, если период ещё не начат).
  BudgetPlan? get currentBudgetPlan => _budgetPlan;

  /// Сохраняет новый подтверждённый план.
  void setBudgetPlan(BudgetPlan plan) {
    _budgetPlan = plan;
  }

  // ─── Прогресс и развитие питомца (требование 8.10) ───

  /// Оценивает завершённый период и начисляет очки роста (0–3).
  /// Критерии:
  ///   +1 — обязательные расходы покрыты (факт ≥ 90% плана)
  ///   +1 — факт необязательных не превысил план (бюджет соблюдён)
  ///   +1 — копилка пополнена (факт ≥ 50% плана накоплений)
  ///
  /// Возвращает: (очки за период, список объяснений, изменилась ли стадия).
  (int, List<String>, bool) evaluatePeriod(PlayerProfile profile, BudgetPlan plan) {
    final points = <int>[];
    final reasons = <String>[];

    // 1. Обязательные расходы покрыты
    final reqOk = plan.requiredSpent >= (plan.requiredAmount * 0.9);
    if (reqOk) {
      points.add(1);
      reasons.add('Обязательные расходы покрыты — питомец сыт и ухожен ✅');
    } else {
      reasons.add('Обязательные расходы не полностью покрыты 🍎');
    }

    // 2. Необязательные не превысили план
    final optOk = plan.optionalSpent <= plan.optionalAmount;
    if (optOk) {
      points.add(1);
      reasons.add('Необязательные траты в рамках плана — разумный выбор 💡');
    } else {
      reasons.add('Необязательные траты превысили план — в следующий раз запланируй больше 🎮');
    }

    // 3. Копилка пополнена
    final savOk = plan.savingsDeposited >= (plan.savingsAmount * 0.5);
    if (savOk) {
      points.add(1);
      reasons.add('Копилка пополнена — ты думаешь о будущем 🏦');
    } else {
      reasons.add('Копилка пополнена мало — попробуй откладывать больше в следующий раз 🐷');
    }

    final earned = points.length;
    final oldStage = _stageForScore(profile.growthScore);

    profile.growthScore += earned;
    final newStage = _stageForScore(profile.growthScore);
    final stageChanged = newStage != oldStage;

    if (stageChanged) {
      profile.petStage = newStage;
      reasons.add(
        stageChanged && newStage > oldStage
            ? '🎉 Питомец вырос: ${PetCharacter.stageName(oldStage)} → ${PetCharacter.stageName(newStage)}!'
            : 'Стадия изменилась: ${PetCharacter.stageName(newStage)}',
      );
    }

    StorageService().saveProfile(profile);
    return (earned, reasons, stageChanged);
  }

  /// Стадия по очкам роста: 0–2 → 1, 3–5 → 2, 6+ → 3.
  int _stageForScore(int score) {
    if (score >= 6) return 3;
    if (score >= 3) return 2;
    return 1;
  }

  /// Завершает текущий период и начинает новый:
  /// — оценивает период (очки роста),
  /// — начисляет периодический доход,
  /// — сбрасывает план.
  ///
  /// Возвращает результат оценки: (очки, объяснения, изменилась ли стадия).
  (int, List<String>, bool) startNewPeriod(PlayerProfile profile) {
    var result = (0, <String>[], false);
    final plan = _budgetPlan;
    if (plan != null && plan.confirmed) {
      result = evaluatePeriod(profile, plan);
      _lastCompletedPlan = plan; // сохраняем для экрана прогресса (8.11)
    }
    _budgetPlan = null;
    grantPeriodIncome(profile);
    return result;
  }

  /// Последний завершённый план (для «Итоги периода» на экране прогресса).
  BudgetPlan? get lastCompletedPlan => _lastCompletedPlan;

  // ─── Очистка ───

  /// Очистка транзакций и плана (при сбросе профиля).
  Future<void> clearAll() async {
    await _txBox.clear();
    _budgetPlan = null;
  }
}
