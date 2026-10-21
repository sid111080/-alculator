import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/models/pet_character.dart';
import '../../core/models/pet_mood.dart';
import '../../core/models/player_profile.dart';
import '../../core/services/game_engine.dart';
import '../../core/services/storage_service.dart';
import '../../widgets/animated_pet.dart';
import '../onboarding/onboarding_screen.dart';

/// Главный экран — HUD v3 (на основе одобренного HUD2):
/// • Питомец в центре (224px), 6 кнопок по окружности.
/// • Настроение: питомец вялый/энергичный + эмодзи рядом с именем.
/// • Сочность: поп, летящие эмодзи, пульс баланса.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final PlayerProfile _profile;

  late final AnimationController _pop;
  late final AnimationController _pulse;
  late final AnimationController _celebrate;

  final List<_FlyEmoji> _flies = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _profile = StorageService().activeProfile ??
        PlayerProfile.create(
          playerName: 'Гость',
          character: PetCharacter.gapTooth,
        );
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _celebrate = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _celebrate.addListener(() {
      if (_celebrate.isCompleted) {
        _flies.clear();
        setState(() {});
      }
    });
    _checkDailyBonus();
  }

  @override
  void dispose() {
    _pop.dispose();
    _pulse.dispose();
    _celebrate.dispose();
    super.dispose();
  }

  PetMood get _mood => computeMood(
        hunger: _profile.petHunger,
        fun: _profile.petFun,
        cleanliness: _profile.petCleanliness,
      );

  Future<void> _checkDailyBonus() async {
    final granted = await GameEngine().grantDailyBonus(_profile);
    if (granted && mounted) {
      _burst('🪙');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Доброе утро! Бонус за вход: +${GameEngine.dailyBonusAmount} 🪙',
            style: const TextStyle(fontSize: 14),
          ),
          backgroundColor: AppTheme.hudGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showOnboarding() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  // ─── Сочность ───

  void _burst(String emoji) {
    setState(() {
      _flies
        ..clear()
        ..addAll(List.generate(
          5,
          (i) => _FlyEmoji(
            emoji,
            _rng.nextDouble() * 120 - 60,
            _rng.nextDouble() * 0.25,
          ),
        ));
    });
    _pop.forward(from: 0);
    _pulse.forward(from: 0);
    _celebrate.forward(from: 0);
  }

  // ─── Действия ───

  void _feedPet() {
    const cost = 10;
    if (_profile.balance < cost) {
      _showFeedback('Не хватает монеток! Выполни задание, чтобы заработать 🪙');
      return;
    }
    final ok = GameEngine().purchase(
      _profile,
      itemName: 'Перекус',
      price: cost,
      isRequired: true,
      effectOnPet: 'Сытость +15',
    );
    if (ok) {
      _burst('🍎');
      _showFeedback('Ням-ням! Сытость +15');
    }
  }

  void _washPet() {
    const cost = 10;
    if (_profile.balance < cost) {
      _showFeedback('Не хватает монеток! Выполни задание, чтобы заработать 🪙');
      return;
    }
    final ok = GameEngine().purchase(
      _profile,
      itemName: 'Ванночка',
      price: cost,
      isRequired: true,
      effectOnPet: 'Чистота +15',
    );
    if (ok) {
      _burst('🫧');
      _showFeedback('Блестит! Чистота +15');
    }
  }

  void _playWithPet() {
    const cost = 10;
    if (_profile.balance < cost) {
      _showFeedback('Не хватает монеток! Выполни задание, чтобы заработать 🪙');
      return;
    }
    final ok = GameEngine().purchase(
      _profile,
      itemName: 'Игра',
      price: cost,
      isRequired: false,
      effectOnPet: 'Веселье +15',
    );
    if (ok) {
      _burst('🎉');
      _showFeedback('Ура! Веселье +15');
    }
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 14)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String get _petName => _profile.petName.isNotEmpty
      ? _profile.petName
      : _profile.character.displayName;

  String _stageLabel(int stage) => switch (stage) {
    1 => '🌱 Малыш',
    2 => '⚡ Подросток',
    3 => '👑 Взрослый',
    _ => '🌱 Малыш',
  };

  @override
  Widget build(BuildContext context) {
    final char = _profile.character;
    final mood = _mood;
    return Scaffold(
      backgroundColor: AppTheme.hudBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildOrbitArea(char, mood)),
          ],
        ),
      ),
    );
  }

  // ─── Шапка ───
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Привет, $_petName!',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.hudBadgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _stageLabel(_profile.petStage),
              style: const TextStyle(
                color: AppTheme.hudBadgeText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showOnboarding,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E5EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline,
                size: 16,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Орбитальная зона: питомец + 6 кнопок по окружности ───
  Widget _buildOrbitArea(PetCharacter char, PetMood mood) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cx = w / 2;
        final cy = h / 2;

        final petRadius = 112.0;
        final btnHalf = 28.0;
        final minRadius = petRadius + btnHalf + 16;
        final maxRadius = (math.min(w, h) / 2) - btnHalf - 8;
        final radius = maxRadius.clamp(minRadius, maxRadius);

        final buttons = <_OrbitBtnDef>[
          _OrbitBtnDef('💰', '${_profile.balance}', AppTheme.hudGreen,
              () => context.go('/budget')),
          _OrbitBtnDef('📝', 'Задачи', AppTheme.hudOrange,
              () => context.go('/tasks'),
              badge: _profile.activeTaskCompleted ? null : '3'),
          _OrbitBtnDef('📅', '${_profile.currentPeriod}/5', AppTheme.hudBlue,
              () => context.go('/progress')),
          _OrbitBtnDef('🎮', 'Поиграть', const Color(0xFFFF6B9D), _playWithPet),
          _OrbitBtnDef('🍎', 'Покормить', const Color(0xFFA78BFA), _feedPet),
          _OrbitBtnDef('🫧', 'Помыть', const Color(0xFF38BDF8), _washPet),
        ];

        // Радиальный градиент — мягкое жёлтое «свечение» за питомцем.
        // ВАЖНО: градиент лежит в КВАДРАТНОЙ коробке (side = min(w,h)),
        // центрированной. Если использовать Positioned.fill (вся зона
        // 390×782), радиальный круг обрезается по узкой стороне
        // прямоугольником → жёсткие вертикальные края («серый
        // прямоугольник»). Квадрат + прозрачный стоп на краю (radius 0.5)
        // дают плавное круговое свечение, как в HTML-макете (320×320 circle).
        final side = math.min(w, h);
        return Stack(
          children: [
            Positioned(
              left: (w - side) / 2,
              top: (h - side) / 2,
              width: side,
              height: side,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.hudRingCenter,
                        AppTheme.hudRingEdge,
                        AppTheme.hudRingEdge.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                      center: Alignment.center,
                      radius: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            // Питомец в центре
            Center(child: _buildPet(char, mood)),

            // 6 кнопок по окружности
            for (int i = 0; i < buttons.length; i++) ...[
              Positioned(
                left: cx + radius * math.cos(_angleFor(i)) - btnHalf,
                top: cy + radius * math.sin(_angleFor(i)) - btnHalf,
                child: _OrbitButton(
                  def: buttons[i],
                  pulse: i == 0 ? _pulse : null,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  double _angleFor(int i) => -math.pi / 2 + i * (2 * math.pi / 6);

  // ─── Питомец + имя + настроение + сочность ───
  Widget _buildPet(PetCharacter char, PetMood mood) {
    final popScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 0.4),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.96), weight: 0.3),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 0.3),
    ]).animate(CurvedAnimation(parent: _pop, curve: Curves.easeInOut));

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Питомец с «попом».
        // ВАЖНО: Container имеет явный размер 224×224 — иначе его дочерний
        // Center расширяется на всю зону и большая тень рендерится серым
        // прямоугольником поверх экрана.
        AnimatedBuilder(
          animation: _pop,
          builder: (context, _) => Transform.scale(
            scale: popScale.value,
            child: Container(
              width: 224,
              height: 224,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: char.color.withValues(alpha: 0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: AnimatedPet(
                character: char,
                stage: _profile.petStage,
                size: 224,
                color: char.color,
                mood: mood,
              ),
            ),
          ),
        ),

        // Летящие эмодзи
        if (_flies.isNotEmpty)
          AnimatedBuilder(
            animation: _celebrate,
            builder: (context, _) {
              final t = _celebrate.value;
              return IgnorePointer(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    for (final f in _flies)
                      if (t > f.delay)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: -30 - ((t - f.delay) / (1 - f.delay)) * 90,
                          child: Opacity(
                            opacity: 1 - ((t - f.delay) / (1 - f.delay)),
                            child: Center(
                              child: Transform.translate(
                                offset: Offset(f.dx, 0),
                                child: Text(
                                  f.emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Летящий праздничный эмодзи.
class _FlyEmoji {
  const _FlyEmoji(this.emoji, this.dx, this.delay);
  final String emoji;
  final double dx;
  final double delay;
}

/// Орбитальная кнопка: увеличение на 20% при нажатии + опциональный пульс.
class _OrbitButton extends StatefulWidget {
  const _OrbitButton({required this.def, this.pulse});
  final _OrbitBtnDef def;
  final AnimationController? pulse;

  @override
  State<_OrbitButton> createState() => _OrbitButtonState();
}

class _OrbitButtonState extends State<_OrbitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final def = widget.def;

    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Круглая иконка
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [def.color, def.color.withValues(alpha: 0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: def.color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(def.icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            // Бейдж
            if (def.badge != null)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      def.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        // Подпись
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            def.label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );

    // Пульс (для кнопки баланса)
    if (widget.pulse != null) {
      final pulseScale = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 0.5),
        TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 0.5),
      ]).animate(CurvedAnimation(parent: widget.pulse!, curve: Curves.easeOut));
      final buttonContent = child;
      child = AnimatedBuilder(
        animation: widget.pulse!,
        builder: (context, _) => Transform.scale(
          scale: pulseScale.value,
          child: buttonContent,
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: def.onTap,
      child: AnimatedScale(
        scale: _pressed ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

/// Описание орбитальной кнопки.
class _OrbitBtnDef {
  const _OrbitBtnDef(this.icon, this.label, this.color, this.onTap, {this.badge});
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;
}
