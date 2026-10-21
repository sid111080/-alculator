import 'dart:math' as math;

/// Настроение питомца — вычисляется из показателей состояния (0–100, выше = лучше).
/// Определяет, как питомец ведёт себя и что «хочет» (пузырь мысли).
enum PetMood { happy, neutral, hungry, dirty, bored }

extension PetMoodInfo on PetMood {
  /// Эмодзи-индикатор нужды/настроения.
  String get emoji => switch (this) {
    PetMood.happy => '💖',
    PetMood.neutral => '🙂',
    PetMood.hungry => '🍎',
    PetMood.dirty => '🫧',
    PetMood.bored => '🎮',
  };

  /// Короткая фраза в «пузыре мысли» (простыми словами, без страха/стыда).
  String get message => switch (this) {
    PetMood.happy => 'Мне хорошо!',
    PetMood.neutral => '',
    PetMood.hungry => 'Хочу есть!',
    PetMood.dirty => 'Хочу в ванну!',
    PetMood.bored => 'Давай играть!',
  };

  /// Показывать ли пузырь мысли (для нейтрального — нет).
  bool get showBubble => this != PetMood.neutral;
}

/// Вычисляет настроение по показателям состояния.
///
/// Логика: если самый низкий показатель ниже порога «нужды» — питомец
/// хочет именно то, что пропало. Если все показатели выше порога «удовлетворения»
/// — питомец счастлив. Иначе — нейтрален.
PetMood computeMood({
  required int hunger,
  required int fun,
  required int cleanliness,
}) {
  const low = 40;
  const happy = 60;

  final lowest = math.min(hunger, math.min(fun, cleanliness));
  if (lowest < low) {
    if (hunger == lowest) return PetMood.hungry;
    if (cleanliness == lowest) return PetMood.dirty;
    return PetMood.bored;
  }
  if (hunger >= happy && fun >= happy && cleanliness >= happy) {
    return PetMood.happy;
  }
  return PetMood.neutral;
}
