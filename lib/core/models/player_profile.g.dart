// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerProfileAdapter extends TypeAdapter<PlayerProfile> {
  @override
  final int typeId = 0;

  @override
  PlayerProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerProfile(
      id: fields[0] as String,
      playerName: fields[1] as String,
      character: fields[2] as PetCharacter,
      createdAt: fields[3] as DateTime,
      hasCompletedOnboarding: fields[4] as bool,
      balance: fields[5] as int,
      savings: fields[6] as int,
      currentPeriod: fields[7] as int,
      petStage: fields[8] as int,
      petName: fields[9] as String,
      petVariant: fields[10] as PetVariant,
      petHunger: fields[11] as int,
      petFun: fields[12] as int,
      petCleanliness: fields[13] as int,
      goalName: fields[14] as String,
      goalTarget: fields[15] as int,
      activeTaskTitle: fields[16] as String,
      activeTaskReward: fields[17] as int,
      activeTaskCompleted: fields[18] as bool,
      growthScore: (fields[19] as int?) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerProfile obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.playerName)
      ..writeByte(2)
      ..write(obj.character)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(5)
      ..write(obj.balance)
      ..writeByte(6)
      ..write(obj.savings)
      ..writeByte(7)
      ..write(obj.currentPeriod)
      ..writeByte(8)
      ..write(obj.petStage)
      ..writeByte(9)
      ..write(obj.petName)
      ..writeByte(10)
      ..write(obj.petVariant)
      ..writeByte(11)
      ..write(obj.petHunger)
      ..writeByte(12)
      ..write(obj.petFun)
      ..writeByte(13)
      ..write(obj.petCleanliness)
      ..writeByte(14)
      ..write(obj.goalName)
      ..writeByte(15)
      ..write(obj.goalTarget)
      ..writeByte(16)
      ..write(obj.activeTaskTitle)
      ..writeByte(17)
      ..write(obj.activeTaskReward)
      ..writeByte(18)
      ..write(obj.activeTaskCompleted)
      ..writeByte(19)
      ..write(obj.growthScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
