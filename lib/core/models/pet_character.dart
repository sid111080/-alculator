import 'package:flutter/material.dart';

/// Персонажи питомцев — 4 вида монстров.
enum PetCharacter {
  gapTooth('GapTooth McGoo', 'Шутник', 0xFF76C8A0),
  oogahBoogah('Oogah Boogah', 'Энергичный', 0xFFFF8C42),
  wideEyedWeirdo('Wide Eyed Weirdo', 'Любознательный', 0xFFB388FF),
  reeko('Reeko', 'Изобретатель', 0xFF4A90D9);

  const PetCharacter(this.displayName, this.personality, this.themeColor);

  final String displayName;
  final String personality;
  final int themeColor;

  Color get color => Color(themeColor);

  /// Краткое описание для экрана выбора.
  String get description => switch (this) {
    PetCharacter.gapTooth => 'Любит шутить и подшучивать. Радость от розыгрышей!',
    PetCharacter.oogahBoogah => 'Безумная энергия и танцы. Никогда не скучно!',
    PetCharacter.wideEyedWeirdo => 'Всегда удивляется и хочет всё узнать.',
    PetCharacter.reeko => 'Изобретает штуки и чинит механизмы.',
  };

  /// SVG-ассет для данной стадии (1 = Малыш, 2 = Подросток, 3 = Взрослый).
  String svgAssetForStage(int stage) {
    final prefix = switch (this) {
      PetCharacter.gapTooth => 'gaptooth',
      PetCharacter.oogahBoogah => 'oogah',
      PetCharacter.wideEyedWeirdo => 'weirdo',
      PetCharacter.reeko => 'reeko',
    };
    final l = stage.clamp(1, 3);
    return 'assets/characters/${prefix}_l$l.svg';
  }

  /// SVG для стадии 1 (для обратной совместимости).
  String get svgAsset => svgAssetForStage(1);

  /// Название стадии.
  static String stageName(int stage) => switch (stage) {
    1 => 'Малыш',
    2 => 'Подросток',
    3 => 'Взрослый',
    _ => 'Малыш',
  };

  /// Эмодзи стадии.
  static String stageEmoji(int stage) => switch (stage) {
    1 => '🌱',
    2 => '⚡',
    3 => '👑',
    _ => '🌱',
  };

  /// Описание стадии (для FeedbackCard при росте).
  static String stageDescription(int stage) => switch (stage) {
    1 => 'Малыш — только начинает учиться управлять деньгами. Маленький, милый и доверчивый.',
    2 => 'Подросток — уже умеет планировать бюджет и копить на цели. Стал крупнее и увереннее!',
    3 => 'Взрослый — настоящий финансовый мастер! Умеет всё: планировать, копить и принимать решения.',
    _ => 'Малыш — только начинает учиться.',
  };
}
