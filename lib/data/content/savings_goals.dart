import '../../core/models/pet_character.dart';

/// Финансовая цель накопления.
class SavingsGoal {
  final String id;
  final String name;
  final String emoji;
  final int cost;
  final String description;
  final PetCharacter character;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cost,
    required this.description,
    required this.character,
  });
}

/// Каталог целей для каждого персонажа (из items.md).
class GoalsCatalog {
  static final List<SavingsGoal> all = [
    // ─── GapTooth McGoo ───
    SavingsGoal(id: 'g1', name: 'Супер-розыгрыш года', emoji: '🎪', cost: 500, description: 'Реквизит для грандиозного розыгрыша', character: PetCharacter.gapTooth),
    SavingsGoal(id: 'g2', name: 'Шоу-программа', emoji: '🎤', cost: 750, description: 'Собственное комедийное выступление', character: PetCharacter.gapTooth),
    SavingsGoal(id: 'g3', name: 'Парк развлечений', emoji: '🎡', cost: 1000, description: 'Личное место для шуток и веселья', character: PetCharacter.gapTooth),

    // ─── Oogah Boogah ───
    SavingsGoal(id: 'o1', name: 'Фестиваль безумия', emoji: '🎉', cost: 600, description: 'Грандиозный праздник', character: PetCharacter.oogahBoogah),
    SavingsGoal(id: 'o2', name: 'Парк аттракционов', emoji: '🎢', cost: 850, description: 'Собственное место развлечений', character: PetCharacter.oogahBoogah),
    SavingsGoal(id: 'o3', name: 'Шоу фейерверков', emoji: '🎆', cost: 1200, description: 'Грандиозное световое представление', character: PetCharacter.oogahBoogah),

    // ─── Wide Eyed Weirdo ───
    SavingsGoal(id: 'w1', name: 'Лаборатория чудес', emoji: '🔬', cost: 400, description: 'Место для исследований', character: PetCharacter.wideEyedWeirdo),
    SavingsGoal(id: 'w2', name: 'Музей необычных вещей', emoji: '🏛️', cost: 700, description: 'Коллекция удивительных предметов', character: PetCharacter.wideEyedWeirdo),
    SavingsGoal(id: 'w3', name: 'Космическая станция', emoji: '🚀', cost: 950, description: 'Собственный центр изучения космоса', character: PetCharacter.wideEyedWeirdo),

    // ─── Reeko ───
    SavingsGoal(id: 'r1', name: 'Мастерская изобретений', emoji: '🏗️', cost: 800, description: 'Собственное пространство для творчества', character: PetCharacter.reeko),
    SavingsGoal(id: 'r2', name: 'Супер-робот', emoji: '🤖', cost: 1100, description: 'Уникальный механический друг', character: PetCharacter.reeko),
    SavingsGoal(id: 'r3', name: 'Научный центр', emoji: '🏫', cost: 1500, description: 'Комплекс для масштабных экспериментов', character: PetCharacter.reeko),
  ];

  /// Цели для конкретного персонажа.
  static List<SavingsGoal> forCharacter(PetCharacter character) =>
      all.where((g) => g.character == character).toList();

  /// Найти цель по имени.
  static SavingsGoal? findByName(String name) =>
      all.where((g) => g.name == name).firstOrNull;
}
