import 'package:hive/hive.dart';

part 'transaction.g.dart';

/// Источник изменения баланса.
enum TransactionSource {
  dailyBonus,
  taskReward,
  periodIncome,
  purchase,
  savingsDeposit,
  savingsWithdraw,
  startingBalance,
}

/// Запись об изменении баланса.
@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  /// Положительное — доход, отрицательное — расход.
  @HiveField(1)
  int amount;

  @HiveField(2)
  TransactionSource source;

  /// Человекочитаемое описание (на русском).
  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime timestamp;

  Transaction({
    required this.id,
    required this.amount,
    required this.source,
    required this.description,
    required this.timestamp,
  });

  factory Transaction.create({
    required int amount,
    required TransactionSource source,
    required String description,
  }) {
    return Transaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      source: source,
      description: description,
      timestamp: DateTime.now(),
    );
  }
}
