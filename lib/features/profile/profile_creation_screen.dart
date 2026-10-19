import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/models/pet_character.dart';
import '../../core/models/player_profile.dart';
import '../../core/services/storage_service.dart';
import '../../widgets/fum.dart';

/// Экран создания профиля (гостевой режим, без регистрации).
/// Требование 8.1: игровое имя + выбранный персонаж.
class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _nameController = TextEditingController();
  PetCharacter? _selectedCharacter;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введи своё имя')),
        );
      }
      return;
    }
    if (_selectedCharacter == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выбери питомца ниже')),
        );
      }
      return;
    }

    try {
      final storage = StorageService();
      final profile = PlayerProfile.create(
        playerName: name,
        character: _selectedCharacter!,
      );
      await storage.setActiveProfile(profile);

      if (mounted) {
        context.go('/pet_creation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Заголовок
              const Text(
                'Создай свой профиль',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Никакой регистрации — просто имя и питомец',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              // Поле имени
              const Text(
                'Как тебя зовут?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 16,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Введи своё имя',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 28),
              // Выбор персонажа
              const Text(
                'Выбери питомца',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Сетка персонажей 2×2
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: PetCharacter.values.map((c) {
                  final isSelected = _selectedCharacter == c;
                  return _CharacterCard(
                    character: c,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCharacter = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // Кнопка создания
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createProfile,
                  child: const Text('Создать профиль'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    required this.isSelected,
    required this.onTap,
  });

  final PetCharacter character;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? character.color.withOpacity(0.12)
              : AppTheme.surface,
          borderRadius: AppTheme.cardRadius,
          border: Border.all(
            color: isSelected ? character.color : const Color(0xFFE0D8CC),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: character.color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Аватар (SVG — Уровень 1)
            FumPetCircle(
              svgAsset: character.svgAsset,
              size: 72,
              color: character.color,
            ),
            const SizedBox(height: 10),
            // Имя
            Text(
              character.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: character.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Характер
            Text(
              character.personality,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            // Галочка выбора
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: character.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
