import 'package:hive/hive.dart';
import 'pet_character.dart';
import 'pet_variant.dart';

part 'player_profile.g.dart';

/// Профиль игрока (гостевой режим, без регистрации).
@HiveType(typeId: 0)
class PlayerProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String playerName;

  @HiveField(2)
  PetCharacter character;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  bool hasCompletedOnboarding;

  /// Текущий баланс игровой валюты.
  @HiveField(5)
  int balance;

  /// Сумма накоплений.
  @HiveField(6)
  int savings;

  /// Текущий игровой период (1–5).
  @HiveField(7)
  int currentPeriod;

  /// Текущая стадия развития питомца (1–3).
  @HiveField(8)
  int petStage;

  /// Имя питомца (вводится на этапе создания питомца).
  @HiveField(9)
  String petName;

  /// Выбранный вариант внешности питомца.
  @HiveField(10)
  PetVariant petVariant;

  /// Сытость питомца (0–100).
  @HiveField(11)
  int petHunger;

  /// Веселье питомца (0–100).
  @HiveField(12)
  int petFun;

  /// Чистота питомца (0–100).
  @HiveField(13)
  int petCleanliness;

  /// Название текущей финансовой цели.
  @HiveField(14)
  String goalName;

  /// Целевая сумма накоплений.
  @HiveField(15)
  int goalTarget;

  /// Название активного задания.
  @HiveField(16)
  String activeTaskTitle;

  /// Награда за активное задание.
  @HiveField(17)
  int activeTaskReward;

  /// Завершено ли активное задание.
  @HiveField(18)
  bool activeTaskCompleted;

  /// Очки роста питомца (накапливаются за периоды).
  /// 0–2 → стадия 1 (Малыш), 3–5 → стадия 2 (Подросток), 6+ → стадия 3 (Взрослый).
  @HiveField(19)
  int growthScore;

  PlayerProfile({
    required this.id,
    required this.playerName,
    required this.character,
    required this.createdAt,
    this.hasCompletedOnboarding = false,
    this.balance = 0,
    this.savings = 0,
    this.currentPeriod = 1,
    this.petStage = 1,
    this.petName = '',
    this.petVariant = PetVariant.gentleGapTooth,
    this.petHunger = 70,
    this.petFun = 70,
    this.petCleanliness = 70,
    this.goalName = '',
    this.goalTarget = 0,
    this.activeTaskTitle = '',
    this.activeTaskReward = 0,
    this.activeTaskCompleted = false,
    this.growthScore = 0,
  });

  /// Стартовый баланс при первом запуске.
  static const int startingBalance = 200;

  factory PlayerProfile.create({
    required String playerName,
    required PetCharacter character,
  }) {
    return PlayerProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerName: playerName,
      character: character,
      createdAt: DateTime.now(),
      balance: startingBalance,
      petHunger: 80,
      petFun: 80,
      petCleanliness: 80,
      // Цель не задаём — ребёнок выберет её на экране «Копилка».
      // (goalName пустой, чтобы не было «фантомной» цели вне каталога)
      activeTaskTitle: 'Посчитай сдачу',
      activeTaskReward: 20,
    );
  }
}
