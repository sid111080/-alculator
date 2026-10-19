import 'package:flutter_test/flutter_test.dart';
import 'package:finny_pet/core/models/pet_character.dart';
import 'package:finny_pet/core/models/pet_variant.dart';

void main() {
  group('PetVariant — 12 комбинаций', () {
    test('Всего 12 вариантов (4 персонажа × 3)', () {
      expect(PetVariant.values.length, 12);
    });

    test('forCharacter возвращает 3 варианта для каждого персонажа', () {
      for (final c in PetCharacter.values) {
        final variants = PetVariant.forCharacter(c);
        expect(variants.length, 3, reason: '$c должен иметь 3 варианта');
      }
    });

    test('Все 12 вариантов имеют уникальные bodyColor', () {
      final colors = PetVariant.values.map((v) => v.bodyColor).toSet();
      expect(colors.length, 12);
    });

    test('Каждый вариант имеет имя и описание', () {
      for (final v in PetVariant.values) {
        expect(v.name.isNotEmpty, isTrue, reason: '$v без имени');
        expect(v.description.isNotEmpty, isTrue, reason: '$v без описания');
      }
    });

    test('Варианты не пересекаются между персонажами', () {
      final sets = PetCharacter.values
          .map((c) => PetVariant.forCharacter(c).toSet())
          .toList();
      for (var i = 0; i < sets.length; i++) {
        for (var j = i + 1; j < sets.length; j++) {
          final intersection = sets[i].intersection(sets[j]);
          expect(
            intersection,
            isEmpty,
            reason: 'Пересечение между $i и $j: $intersection',
          );
        }
      }
    });
  });
}
