import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/models/pet_character.dart';
import '../../core/models/player_profile.dart';
import '../../core/services/game_engine.dart';
import '../../core/services/storage_service.dart';
import '../../widgets/animated_pet.dart';
import '../onboarding/onboarding_screen.dart';

/// Главный экран — HUD v2: питомец в центре (увеличен на 70%),
/// 6 орбитальных кнопок вокруг (баланс, задачи, период, поиграть,
/// покормить, помыть). Все ключевые элементы видны одновременно.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PlayerProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = StorageService().activeProfile ??
        PlayerProfile.create(
          playerName: 'Гость',
          character: PetCharacter.gapTooth,
        );
    _checkDailyBonus();
  }

  Future<void> _checkDailyBonus() async {
    final granted = await GameEngine().grantDailyBonus(_profile);
    if (granted && mounted) {
      setState(() {});
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

  // ─── Быстрые действия с питомцем ───

  void _feedPet() {
    final engine = GameEngine();
    final cost = 10;
    if (_profile.balance < cost) {
      _showFeedback('Не хватает монеток! Выполни задание, чтобы заработать 🪙');
      return;
    }
    engine.purchase(
      _profile,
      itemName: 'Перекус',
      price: cost,
      isRequired: true,
      effectOnPet: 'Сытость +15',
    );
    setState(() {});
    _showFeedback('Ням-ням! Сытость +15 🍎');
  }

  void _washPet() {
    final engine = GameEngine();
    final cost = 10;
    if (_profile.balance < cost) {
      _showFeedback('Не хватает монеток! Выполни задание, чтобы заработать 🪙');
      return;
    }
    engine.purchase(
      _profile,
      itemName: 'Ванночка',
      price: cost,
      isRequired: true,
      effectOnPet: 'Чистота +15',
    );
    setState(() {});
    _showFeedback('Блестит! Чистота +15 🫧');
  }

  void _playWithPet() {
    final engine = GameEngine();
    final cost = 10;
    if (_profile.balance < cost) {
      _showFeedback('Не хватает монеток! Выполни задание, чтобы заработать 🪙');
      return;
    }
    engine.purchase(
      _profile,
      itemName: 'Игра',
      price: cost,
      isRequired: false,
      effectOnPet: 'Веселье +15',
    );
    setState(() {});
    _showFeedback('Ура! Веселье +15 🎮');
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
    return Scaffold(
      backgroundColor: AppTheme.hudBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildOrbitArea(char)),
          ],
        ),
      ),
    );
  }

  // ─── Шапка: приветствие + бейдж стадии + помощь ───
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
  Widget _buildOrbitArea(PetCharacter char) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cx = w / 2;
        final cy = h / 2;

        // Радиус орбиты: достаточно велик, чтобы кнопки не перекрывали
        // питомец (224px), но помещается в доступное пространство.
        final petRadius = 112.0; // 224 / 2
        final btnHalf = 28.0; // 52 / 2
        final minRadius = petRadius + btnHalf + 16; // 156
        final maxRadius = (math.min(w, h) / 2) - btnHalf - 8;
        final radius = maxRadius.clamp(minRadius, maxRadius);

        // 6 кнопок равномерно по окружности, начиная с верха (−90°)
        // Порядок: баланс, задачи, период, поиграть, покормить, помыть
        final buttons = <_OrbitBtnDef>[
          _OrbitBtnDef('💰', '${_profile.balance}', AppTheme.hudGreen, () => context.go('/budget')),
          _OrbitBtnDef('📝', 'Задачи', AppTheme.hudOrange, () => context.go('/tasks'),
              badge: _profile.activeTaskCompleted ? null : '3'),
          _OrbitBtnDef('📅', '${_profile.currentPeriod}/5', AppTheme.hudBlue, () => context.go('/progress')),
          _OrbitBtnDef('🎮', 'Поиграть', const Color(0xFFFF6B9D), _playWithPet),
          _OrbitBtnDef('🍎', 'Покормить', const Color(0xFFA78BFA), _feedPet),
          _OrbitBtnDef('🫧', 'Помыть', const Color(0xFF38BDF8), _washPet),
        ];

        return Stack(
          children: [
            // Радиальный градиент (жёлтое «кольцо»)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [AppTheme.hudRingCenter, AppTheme.hudRingEdge],
                      center: const Alignment(0, 0),
                      radius: 0.75,
                    ),
                  ),
                ),
              ),
            ),

            // Питомец в центре
            Center(child: _buildPet(char)),

            // 6 орбитальных кнопок по окружности
            for (int i = 0; i < buttons.length; i++) ...[
              Positioned(
                left: cx + radius * math.cos(_angleFor(i)) - btnHalf,
                top: cy + radius * math.sin(_angleFor(i)) - btnHalf,
                child: _OrbitButton(def: buttons[i]),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Угол i-й кнопки (в радианах). 6 кнопок → шаг 60°, старт с верха (−90°).
  double _angleFor(int i) => -math.pi / 2 + i * (2 * math.pi / 6);

  // ─── Питомец (увеличен на 70%: 132 → 224) с анимацией по персонажу ───
  Widget _buildPet(PetCharacter char) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: char.color.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: AnimatedPet(
            character: char,
            stage: _profile.petStage,
            size: 224,
            color: char.color,
          ),
        ),
        const SizedBox(height: 4),
        // Имя питомца
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _petName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

}

/// Орбитальная кнопка с анимацией увеличения на 20% при нажатии.
class _OrbitButton extends StatefulWidget {
  const _OrbitButton({required this.def});
  final _OrbitBtnDef def;

  @override
  State<_OrbitButton> createState() => _OrbitButtonState();
}

class _OrbitButtonState extends State<_OrbitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final def = widget.def;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: def.onTap,
      child: AnimatedScale(
        scale: _pressed ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
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
                // Бейдж-уведомление
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
        ),
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
