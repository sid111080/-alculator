import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/models/pet_character.dart';
import 'fum.dart';

/// Анимированный аватар питомца.
///
/// Анимация зависит от персонажа и стадии (по LevelsFUM.md, раздел
/// «Анимация/поведение»). Для уровня 1 (Малыш) у каждого персонажа
/// своё поведение:
///   • GapTooth — подпрыгивает на месте
///   • Oogah    — крутится на месте
///   • Weirdo   — медленно качает головой
///   • Reeko    — переминается с лапы на лапу
///
/// Прочие стадии пока используют базовое «дыхание» (пульс масштаба).
/// Анимация — встроенные трансформации Flutter (без Lottie), работает офлайн.
class AnimatedPet extends StatefulWidget {
  const AnimatedPet({
    super.key,
    required this.character,
    required this.stage,
    required this.size,
    this.color,
  });

  final PetCharacter character;
  final int stage;
  final double size;
  final Color? color;

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
      duration: _durationFor(widget.character, widget.stage),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedPet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Смена персонажа или стадии → перезапуск с новым темпом.
    if (oldWidget.character != widget.character ||
        oldWidget.stage != widget.stage) {
      _controller
        ..duration = _durationFor(widget.character, widget.stage)
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Длительность одного цикла анимации.
  Duration _durationFor(PetCharacter c, int stage) {
    if (stage == 1) {
      return switch (c) {
        PetCharacter.gapTooth => const Duration(milliseconds: 900),
        PetCharacter.oogahBoogah => const Duration(milliseconds: 1600),
        PetCharacter.wideEyedWeirdo => const Duration(milliseconds: 2600),
        PetCharacter.reeko => const Duration(milliseconds: 1400),
      };
    }
    // Прочие стадии — базовое «дыхание».
    return const Duration(milliseconds: 2600);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? widget.character.color;

    // AnimatedBuilder слушает контроллер и перерисовывает питомца
    // каждый кадр → анимация идёт сама по себе непрерывно,
    // а не только при перерисовке родителя (нажатии на кнопку).
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.value * 2 * math.pi;

        final pet = FumPetCircle(
          svgAsset: widget.character.svgAssetForStage(widget.stage),
          size: widget.size,
          color: color,
        );

        final Widget animated;
        if (widget.stage == 1) {
          switch (widget.character) {
            case PetCharacter.gapTooth:
              animated = _gapTooth(pet, phase);
            case PetCharacter.oogahBoogah:
              animated = _oogah(pet, phase);
            case PetCharacter.wideEyedWeirdo:
              animated = _weirdo(pet, phase);
            case PetCharacter.reeko:
              animated = _reeko(pet, phase);
          }
        } else {
          // Прочие стадии — базовое «дыхание» (пульс масштаба 0.98–1.02).
          final breathe = 1.0 + 0.02 * math.sin(phase);
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
  // Прыжок вверх + «сквош» на земле и «стретч» в воздухе.
  Widget _gapTooth(Widget pet, double phase) {
    final s = widget.size;
    // (1 - cos) / 2: плавный цикл 0 (на земле) → 1 (в воздухе) → 0.
    final inAir = (1 - math.cos(phase)) / 2;
    final dy = -inAir * s * 0.06;
    final ground = 1 - inAir;
    return Transform.translate(
      offset: Offset(0, dy),
      child: Transform.scale(
        alignment: Alignment.center,
        scaleX: 1 + 0.08 * ground,
        scaleY: 1 - 0.08 * ground,
        child: pet,
      ),
    );
  }

  // ─── Oogah: крутится на месте ───
  // Энергичное вращение (безумная энергия персонажа).
  Widget _oogah(Widget pet, double phase) {
    return Transform.rotate(
      angle: math.sin(phase) * 0.7,
      alignment: Alignment.center,
      child: pet,
    );
  }

  // ─── Weirdo: медленно качает головой ───
  // Медленное, небольшое покачивание (наивный, задумчивый).
  Widget _weirdo(Widget pet, double phase) {
    return Transform.rotate(
      angle: math.sin(phase) * 0.15,
      alignment: Alignment.center,
      child: pet,
    );
  }

  // ─── Reeko: переминается с лапы на лапу ───
  // Горизонтальный сдвиг + лёгкий наклон (теребит «детали»).
  Widget _reeko(Widget pet, double phase) {
    final s = widget.size;
    final dx = math.sin(phase) * s * 0.05;
    return Transform.translate(
      offset: Offset(dx, 0),
      child: Transform.rotate(
        angle: math.sin(phase) * 0.08,
        alignment: Alignment.center,
        child: pet,
      ),
    );
  }
}
