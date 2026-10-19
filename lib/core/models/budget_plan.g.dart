// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetPlanAdapter extends TypeAdapter<BudgetPlan> {
  @override
  final int typeId = 4;

  @override
  BudgetPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetPlan(
      periodNumber: fields[0] as int,
      requiredAmount: fields[1] as int,
      optionalAmount: fields[2] as int,
      savingsAmount: fields[3] as int,
      confirmed: fields[4] as bool,
      requiredSpent: fields[5] as int,
      optionalSpent: fields[6] as int,
      savingsDeposited: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetPlan obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.periodNumber)
      ..writeByte(1)
      ..write(obj.requiredAmount)
      ..writeByte(2)
      ..write(obj.optionalAmount)
      ..writeByte(3)
      ..write(obj.savingsAmount)
      ..writeByte(4)
      ..write(obj.confirmed)
      ..writeByte(5)
      ..write(obj.requiredSpent)
      ..writeByte(6)
      ..write(obj.optionalSpent)
      ..writeByte(7)
      ..write(obj.savingsDeposited);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
