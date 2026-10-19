import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget_plan.dart';
import '../models/pet_character.dart';
import '../models/pet_variant.dart';
import '../models/player_profile.dart';
import '../models/transaction.dart';

/// Адаптер для enum — хранит индекс.
class _EnumAdapter<T extends Enum> extends TypeAdapter<T> {
  _EnumAdapter(this.typeId, this.values);
  final int typeId;
  final List<T> values;

  @override
  T read(BinaryReader reader) => values[reader.read()];

  @override
  void write(BinaryWriter writer, T obj) => writer.write(obj.index);

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _EnumAdapter<T> &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Сервис локального хранилища (Hive).
/// Синглтон — один экземпляр на всё приложение.
class StorageService {
  StorageService._();
  static final StorageService _instance = StorageService._();

  /// Единственный экземпляр.
  factory StorageService() => _instance;

  late Box<PlayerProfile> _profilesBox;

  static const String _profilesBoxName = 'profiles';
  static const String _activeProfileKey = 'active_profile_id';

  /// Инициализация для приложения (Hive в каталоге документов).
  Future<void> init() async {
    await Hive.initFlutter();
    await _setup();
  }

  /// Инициализация для тестов — без path_provider (Hive.init в произвольной папке).
  Future<void> initAt(String path) async {
    Hive.init(path);
    await _setup();
  }

  Future<void> _setup() async {
    Hive.registerAdapter(PlayerProfileAdapter());
    Hive.registerAdapter(_EnumAdapter<PetCharacter>(1, PetCharacter.values));
    Hive.registerAdapter(_EnumAdapter<PetVariant>(2, PetVariant.values));
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(BudgetPlanAdapter());
    _profilesBox = await Hive.openBox<PlayerProfile>(_profilesBoxName);
  }

  /// Активный профиль (id хранится отдельно).
  PlayerProfile? get activeProfile {
    if (!Hive.isBoxOpen('settings')) return null;
    final id = Hive.box<String>('settings').get(_activeProfileKey);
    if (id == null) return null;
    return _profilesBox.get(id);
  }

  Future<void> setActiveProfile(PlayerProfile profile) async {
    final settings = await Hive.openBox<String>('settings');
    await settings.put(_activeProfileKey, profile.id);
    await _profilesBox.put(profile.id, profile);
  }

  Future<void> saveProfile(PlayerProfile profile) async {
    await _profilesBox.put(profile.id, profile);
  }

  /// Сброс профиля — удаляет все игровые данные.
  Future<void> resetProfile(PlayerProfile profile) async {
    await _profilesBox.delete(profile.id);
    final settings = Hive.box<String>('settings');
    await settings.delete(_activeProfileKey);
  }

  /// Удаление всех профилей.
  Future<void> deleteAll() async {
    await _profilesBox.clear();
    final settings = Hive.box<String>('settings');
    await settings.clear();
  }
}
