import '../../core/models/pet_character.dart';

/// Тип товара.
enum ShopItemType { required, optional }

/// Товар в магазине.
class ShopItem {
  final String id;
  final String name;
  final String emoji;
  final int price;
  final ShopItemType type;
  final String effectOnPet;
  final PetCharacter character;

  const ShopItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.type,
    required this.effectOnPet,
    required this.character,
  });
}

/// Каталог товаров для каждого персонажа (из items.md).
class ShopCatalog {
  static final List<ShopItem> all = [
    // ─── GapTooth McGoo ───
    ShopItem(id: 'gt1', name: 'Зубная паста для щербинки', emoji: '🦷', price: 50, type: ShopItemType.required, effectOnPet: 'Сытость +10', character: PetCharacter.gapTooth),
    ShopItem(id: 'gt2', name: 'Набор шуток', emoji: '😂', price: 30, type: ShopItemType.required, effectOnPet: 'Веселье +10', character: PetCharacter.gapTooth),
    ShopItem(id: 'gt3', name: 'Лакомства для розыгрышей', emoji: '🍬', price: 40, type: ShopItemType.required, effectOnPet: 'Сытость +15', character: PetCharacter.gapTooth),
    ShopItem(id: 'gt4', name: 'Костюм для подшучиваний', emoji: '🎭', price: 60, type: ShopItemType.required, effectOnPet: 'Чистота +10', character: PetCharacter.gapTooth),
    ShopItem(id: 'gt5', name: 'Набор для пранков', emoji: '🤡', price: 100, type: ShopItemType.optional, effectOnPet: 'Веселье +20', character: PetCharacter.gapTooth),
    ShopItem(id: 'gt6', name: 'Зеркальце для самолюбования', emoji: '🪞', price: 70, type: ShopItemType.optional, effectOnPet: 'Настроение +15', character: PetCharacter.gapTooth),
    ShopItem(id: 'gt7', name: 'Набор наклеек', emoji: '✨', price: 80, type: ShopItemType.optional, effectOnPet: 'Веселье +15', character: PetCharacter.gapTooth),
    ShopItem(id: 'gt8', name: 'Новые очки', emoji: '👓', price: 90, type: ShopItemType.optional, effectOnPet: 'Настроение +20', character: PetCharacter.gapTooth),

    // ─── Oogah Boogah ───
    ShopItem(id: 'ob1', name: 'Энергетический напиток', emoji: '⚡', price: 45, type: ShopItemType.required, effectOnPet: 'Сытость +10', character: PetCharacter.oogahBoogah),
    ShopItem(id: 'ob2', name: 'Набор для танцев', emoji: '💃', price: 55, type: ShopItemType.required, effectOnPet: 'Веселье +10', character: PetCharacter.oogahBoogah),
    ShopItem(id: 'ob3', name: 'Аксессуары для причёсок', emoji: '🎀', price: 65, type: ShopItemType.required, effectOnPet: 'Чистота +10', character: PetCharacter.oogahBoogah),
    ShopItem(id: 'ob4', name: 'Билеты на веселье', emoji: '🎟️', price: 75, type: ShopItemType.required, effectOnPet: 'Веселье +15', character: PetCharacter.oogahBoogah),
    ShopItem(id: 'ob5', name: 'Костюм для вечеринок', emoji: '🥳', price: 120, type: ShopItemType.optional, effectOnPet: 'Веселье +25', character: PetCharacter.oogahBoogah),
    ShopItem(id: 'ob6', name: 'Набор игрушек', emoji: '🧸', price: 90, type: ShopItemType.optional, effectOnPet: 'Настроение +15', character: PetCharacter.oogahBoogah),
    ShopItem(id: 'ob7', name: 'Билеты на аттракционы', emoji: '🎢', price: 110, type: ShopItemType.optional, effectOnPet: 'Веселье +20', character: PetCharacter.oogahBoogah),
    ShopItem(id: 'ob8', name: 'Набор для фокусов', emoji: '🎩', price: 100, type: ShopItemType.optional, effectOnPet: 'Настроение +20', character: PetCharacter.oogahBoogah),

    // ─── Wide Eyed Weirdo ───
    ShopItem(id: 'we1', name: 'Книги-раскраски', emoji: '📖', price: 35, type: ShopItemType.required, effectOnPet: 'Сытость +10', character: PetCharacter.wideEyedWeirdo),
    ShopItem(id: 'we2', name: 'Набор для экспериментов', emoji: '🧪', price: 45, type: ShopItemType.required, effectOnPet: 'Веселье +10', character: PetCharacter.wideEyedWeirdo),
    ShopItem(id: 'we3', name: 'Лупа для изучения', emoji: '🔍', price: 50, type: ShopItemType.required, effectOnPet: 'Чистота +10', character: PetCharacter.wideEyedWeirdo),
    ShopItem(id: 'we4', name: 'Сладости для размышлений', emoji: '🍩', price: 40, type: ShopItemType.required, effectOnPet: 'Сытость +15', character: PetCharacter.wideEyedWeirdo),
    ShopItem(id: 'we5', name: 'Телескоп', emoji: '🔭', price: 150, type: ShopItemType.optional, effectOnPet: 'Веселье +25', character: PetCharacter.wideEyedWeirdo),
    ShopItem(id: 'we6', name: 'Микроскоп', emoji: '🔬', price: 130, type: ShopItemType.optional, effectOnPet: 'Настроение +20', character: PetCharacter.wideEyedWeirdo),
    ShopItem(id: 'we7', name: 'Набор для творчества', emoji: '🎨', price: 100, type: ShopItemType.optional, effectOnPet: 'Веселье +20', character: PetCharacter.wideEyedWeirdo),
    ShopItem(id: 'we8', name: 'Карта звёздного неба', emoji: '🌌', price: 120, type: ShopItemType.optional, effectOnPet: 'Настроение +25', character: PetCharacter.wideEyedWeirdo),

    // ─── Reeko ───
    ShopItem(id: 'rk1', name: 'Детали для изобретений', emoji: '⚙️', price: 60, type: ShopItemType.required, effectOnPet: 'Сытость +10', character: PetCharacter.reeko),
    ShopItem(id: 'rk2', name: 'Инструменты', emoji: '🔧', price: 70, type: ShopItemType.required, effectOnPet: 'Веселье +10', character: PetCharacter.reeko),
    ShopItem(id: 'rk3', name: 'Запчасти', emoji: '🔩', price: 80, type: ShopItemType.required, effectOnPet: 'Чистота +10', character: PetCharacter.reeko),
    ShopItem(id: 'rk4', name: 'Энергетический коктейль', emoji: '🥤', price: 50, type: ShopItemType.required, effectOnPet: 'Сытость +15', character: PetCharacter.reeko),
    ShopItem(id: 'rk5', name: 'Набор схем', emoji: '📐', price: 140, type: ShopItemType.optional, effectOnPet: 'Веселье +20', character: PetCharacter.reeko),
    ShopItem(id: 'rk6', name: 'Экспериментальная лаборатория', emoji: '🏭', price: 160, type: ShopItemType.optional, effectOnPet: 'Настроение +25', character: PetCharacter.reeko),
    ShopItem(id: 'rk7', name: 'Роботизированные части', emoji: '🤖', price: 180, type: ShopItemType.optional, effectOnPet: 'Веселье +25', character: PetCharacter.reeko),
    ShopItem(id: 'rk8', name: 'Набор для пайки', emoji: '🔥', price: 150, type: ShopItemType.optional, effectOnPet: 'Настроение +20', character: PetCharacter.reeko),
  ];

  /// Товары для конкретного персонажа.
  static List<ShopItem> forCharacter(PetCharacter character) =>
      all.where((item) => item.character == character).toList();

  /// Обязательные для персонажа.
  static List<ShopItem> required(PetCharacter character) =>
      all.where((i) => i.character == character && i.type == ShopItemType.required).toList();

  /// Необязательные для персонажа.
  static List<ShopItem> optional(PetCharacter character) =>
      all.where((i) => i.character == character && i.type == ShopItemType.optional).toList();
}
