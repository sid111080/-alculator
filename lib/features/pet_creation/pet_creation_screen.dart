import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/models/pet_character.dart';
import '../../core/models/pet_variant.dart';
import '../../core/services/storage_service.dart';

/// Экран создания питомца (требование 8.2).
/// Настройка внешнего вида (3 варианта на персонажа = 12 комбинаций)
/// + ввод игрового имени питомца.
class PetCreationScreen extends StatefulWidget {
  const PetCreationScreen({super.key});

  @override
  State<PetCreationScreen> createState() => _PetCreationScreenState();
}

class _PetCreationScreenState extends State<PetCreationScreen> {
  final _nameController = TextEditingController();
  PetVariant? _selectedVariant;

  late final PetCharacter _character;
  late final List<PetVariant> _variants;

  @override
  void initState() {
    super.initState();
    // Персонаж уже выбран на предыдущем шаге.
    final storage = StorageService();
    final profile = storage.activeProfile;
    _character = profile?.character ?? PetCharacter.gapTooth;
    _variants = PetVariant.forCharacter(_character);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createPet() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedVariant == null) return;

    final storage = StorageService();
    final profile = storage.activeProfile;
    if (profile == null) return;

    profile.petName = name;
    profile.petVariant = _selectedVariant!;
    await storage.saveProfile(profile);

    if (mounted) {
      context.go('/home');
    }
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty && _selectedVariant != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              // Заголовок
              Text(
                'Создай своего питомца!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Выбери внешний вид и придумай имя',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Превью питомца
              _PetPreview(
                character: _character,
                variant: _selectedVariant,
              ),
              const SizedBox(height: 24),
              // Выбор варианта внешности
              Text(
                'Выбери цвет',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _variants.map((v) {
                  final isSelected = _selectedVariant == v;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _VariantChip(
                      variant: v,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedVariant = v),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              // Поле имени питомца
              Text(
                'Как назовёшь питомца?',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 14,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Имя питомца',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 32),
              // Кнопка
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _createPet : null,
                  child: const Text('Начать приключение! 🎉'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Превью питомца — круглый аватар с цветом выбранного варианта.
class _PetPreview extends StatelessWidget {
  const _PetPreview({
    required this.character,
    required this.variant,
  });

  final PetCharacter character;
  final PetVariant? variant;

  @override
  Widget build(BuildContext context) {
    final color = variant?.body ?? character.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG персонажа (Уровень 1)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              character.svgAsset,
              fit: BoxFit.contain,
            ),
          ),
          // Имя персонажа
          const SizedBox(height: 4),
          Text(
            character.displayName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Чип выбора варианта внешности.
class _VariantChip extends StatelessWidget {
  const _VariantChip({
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  final PetVariant variant;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? variant.body.withValues(alpha: 0.15)
              : AppTheme.surface,
          borderRadius: AppTheme.cardRadius,
          border: Border.all(
            color: isSelected ? variant.body : const Color(0xFFE0D8CC),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: variant.body.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Круг с цветом
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [variant.body, variant.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Название варианта
            Text(
              variant.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? variant.body : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            // Галочка
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: variant.body,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
