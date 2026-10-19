import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/theme.dart';

/// Переиспользуемые виджеты в стиле Funny Ugly Monster.

/// Карточка с асимметричным скруглением и текстурой.
class FumCard extends StatelessWidget {
  const FumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppTheme.surface,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: const Color(0xFFD0C8BC), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Бейдж/тег с округлой формой.
class FumTag extends StatelessWidget {
  const FumTag({
    super.key,
    required this.label,
    this.color = AppTheme.primary,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Круглая иконка-аватар питомца.
/// Поддерживает SVG-ассет (приоритет) или эмодзи-fallback.
class FumPetCircle extends StatelessWidget {
  const FumPetCircle({
    super.key,
    this.svgAsset,
    this.emoji,
    this.size = 120,
    this.color = AppTheme.primary,
  });

  final String? svgAsset;
  final String? emoji;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 3),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: svgAsset != null
              ? SvgPicture.asset(svgAsset!, fit: BoxFit.contain)
              : Text(emoji ?? '🐾', style: TextStyle(fontSize: size * 0.5)),
        ),
      ),
    );
  }
}
