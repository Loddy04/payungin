// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GearItemAdapter extends TypeAdapter<GearItem> {
  @override
  final int typeId = 2;

  @override
  GearItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GearItem(
      name: fields[0] as String,
      quantity: fields[1] as int,
      isReady: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GearItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.isReady);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GearItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
