import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/models/pet_character.dart';
import '../core/models/pet_mood.dart';
import 'fum.dart';

/// Анимированный аватар питомца.
///
/// Анимация зависит от персонажа, стадии и настроения:
/// • Персонаж задаёт «характер» движения (по LevelsFUM.md, ур. 1):
///   GapTooth — прыгает, Oogah — крутится, Weirdo — качает головой,
///   Reeko — переминается.
/// • Настроение (mood) задаёт «энергию»: счастливый — энергичнее,
///   голодный/грязный/скучающий — вялее и медленнее.
/// • Прочие стадии — базовое «дыхание».
///
/// Анимация — встроенные трансформации Flutter (без Lottie), офлайн.
/// `SvgPicture` остаётся в дереве (внутри `FumPetCircle`).
class AnimatedPet extends StatefulWidget {
  const AnimatedPet({
    super.key,
    required this.character,
    required this.stage,
    required this.size,
    this.color,
    this.mood = PetMood.neutral,
  });

  final PetCharacter character;
  final int stage;
  final double size;
  final Color? color;

  /// Настроение питомца — влияет на «энергию» движения.
  final PetMood mood;

  @override
  State<AnimatedPet> createState() => _AnimatedPetState();
}

class _AnimatedPetState extends State<AnimatedPet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _durationFor(widget),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedPet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Смена персонажа, стадии или настроения → перезапуск с новым темпом.
    if (oldWidget.character != widget.character ||
        oldWidget.stage != widget.stage ||
        oldWidget.mood != widget.mood) {
      _controller
        ..duration = _durationFor(widget)
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Длительность цикла: настроение замедляет «вялого» питомца.
  Duration _durationFor(AnimatedPet w) {
    final base = w.stage == 1
        ? switch (w.character) {
            PetCharacter.gapTooth => 900,
            PetCharacter.oogahBoogah => 1600,
            PetCharacter.wideEyedWeirdo => 2600,
            PetCharacter.reeko => 1400,
          }
        : 2600;
    // Счастливый — чуть быстрее (энергия), нуждающийся — медленнее (вялость).
    final factor = switch (w.mood) {
      PetMood.happy => 0.8,
      PetMood.neutral => 1.0,
      PetMood.hungry || PetMood.dirty || PetMood.bored => 1.4,
    };
    return Duration(milliseconds: (base * factor).round());
  }

  /// Множитель амплитуды: счастливый двигается размашистее, вялый — скромнее.
  double get _energy => switch (widget.mood) {
    PetMood.happy => 1.3,
    PetMood.neutral => 1.0,
    PetMood.hungry || PetMood.dirty || PetMood.bored => 0.55,
  };

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? widget.character.color;

    // AnimatedBuilder слушает контроллер → питомец анимируется сам,
    // каждый кадр, а не только при перерисовке родителя.
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.value * 2 * math.pi;
        final e = _energy;

        final pet = FumPetCircle(
          svgAsset: widget.character.svgAssetForStage(widget.stage),
          size: widget.size,
          color: color,
        );

        final Widget animated;
        if (widget.stage == 1) {
          switch (widget.character) {
            case PetCharacter.gapTooth:
              animated = _gapTooth(pet, phase, e);
            case PetCharacter.oogahBoogah:
              animated = _oogah(pet, phase, e);
            case PetCharacter.wideEyedWeirdo:
              animated = _weirdo(pet, phase, e);
            case PetCharacter.reeko:
              animated = _reeko(pet, phase, e);
          }
        } else {
          // Прочие стадии — базовое «дыхание» (пульс масштаба 0.98–1.02).
          final breathe = 1.0 + 0.02 * e * math.sin(phase);
          animated = Transform.scale(
            scale: breathe,
            alignment: Alignment.center,
            child: pet,
          );
        }

        return Center(child: animated);
      },
    );
  }

  // ─── GapTooth: подпрыгивает на месте ───
  Widget _gapTooth(Widget pet, double phase, double e) {
    final s = widget.size;
    final inAir = (1 - math.cos(phase)) / 2; // 0 на земле → 1 в воздухе
    final dy = -inAir * s * 0.06 * e;
    final ground = 1 - inAir;
    return Transform.translate(
      offset: Offset(0, dy),
      child: Transform.scale(
        alignment: Alignment.center,
        scaleX: 1 + 0.08 * e * ground,
        scaleY: 1 - 0.08 * e * ground,
        child: pet,
      ),
    );
  }

  // ─── Oogah: крутится на месте ───
  Widget _oogah(Widget pet, double phase, double e) {
    return Transform.rotate(
      angle: math.sin(phase) * 0.7 * e,
      alignment: Alignment.center,
      child: pet,
    );
  }

  // ─── Weirdo: медленно качает головой ───
  Widget _weirdo(Widget pet, double phase, double e) {
    return Transform.rotate(
      angle: math.sin(phase) * 0.15 * e,
      alignment: Alignment.center,
      child: pet,
    );
  }

  // ─── Reeko: переминается с лапы на лапу ───
  Widget _reeko(Widget pet, double phase, double e) {
    final s = widget.size;
    final dx = math.sin(phase) * s * 0.05 * e;
    return Transform.translate(
      offset: Offset(dx, 0),
      child: Transform.rotate(
        angle: math.sin(phase) * 0.08 * e,
        alignment: Alignment.center,
        child: pet,
      ),
    );
  }
}
