import 'package:flutter/material.dart';
import 'pet_character.dart';

/// Вариант внешности питомца.
/// 4 персонажа × 3 варианта = 12 визуально различимых комбинаций.
enum PetVariant {
  // GapTooth McGoo
  gentleGapTooth('Нежный', 'Мягкий лаймовый', 0xFF8FBF6F, 0xFF5A7A4A),
  brightGapTooth('Яркий', 'Кислотный лайм + розовый', 0xFF76C8A0, 0xFFFF69B4),
  acidGapTooth('Кислотный', 'Неоновый + граффити', 0xFF39FF14, 0xFFFFD700),

  // Oogah Boogah
  warmOogah('Тёплый', 'Мягкий оранжевый', 0xFFE8A87C, 0xFF6B3A2A),
  tangerineOogah('Мандариновый', 'Насыщенный + контраст', 0xFFFF8C42, 0xFF3A1A0A),
  neonOogah('Неоновый', 'Флуоресцентный', 0xFFFF4500, 0xFF1A0A00),

  // Wide Eyed Weirdo
  pastelWeirdo('Пастельный', 'Нежный фиолетовый', 0xFFC9A8E8, 0xFF7A8BAA),
  vividWeirdo('Насыщенный', 'Яркий фиолетовый', 0xFFB388FF, 0xFF4A3A6A),
  iridescentWeirdo('Перелив', 'Переливы + рваные пятна', 0xFF9B59B6, 0xFF2C1A4A),

  // Reeko
  calmReeko('Спокойный', 'Приглушённый синий', 0xFF4A6A8A, 0xFFC8A832),
  boldReeko('Смелый', 'Яркий синий + красный', 0xFF2C5AA0, 0xFFE84A4A),
  darkReeko('Тёмный', 'Глубокий синий + неон', 0xFF1A2A5A, 0xFF00E5FF);

  const PetVariant(this.name, this.description, this.bodyColor, this.accentColor);

  final String name;
  final String description;
  final int bodyColor;
  final int accentColor;

  Color get body => Color(bodyColor);
  Color get accent => Color(accentColor);

  /// Какие варианты доступны для данного персонажа.
  static List<PetVariant> forCharacter(PetCharacter character) => switch (character) {
    PetCharacter.gapTooth => [gentleGapTooth, brightGapTooth, acidGapTooth],
    PetCharacter.oogahBoogah => [warmOogah, tangerineOogah, neonOogah],
    PetCharacter.wideEyedWeirdo => [pastelWeirdo, vividWeirdo, iridescentWeirdo],
    PetCharacter.reeko => [calmReeko, boldReeko, darkReeko],
  };
}
