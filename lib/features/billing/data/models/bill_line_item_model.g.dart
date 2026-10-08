// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_line_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillLineItemModelAdapter extends TypeAdapter<BillLineItemModel> {
  @override
  final int typeId = 1;

  @override
  BillLineItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillLineItemModel(
      productId: fields[0] as String,
      productName: fields[1] as String,
      priceTierIndex: fields[2] as int,
      priceTierLabel: fields[3] as String,
      unitPrice: fields[4] as double,
      quantity: fields[5] as int,
      lineTotal: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, BillLineItemModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.priceTierIndex)
      ..writeByte(3)
      ..write(obj.priceTierLabel)
      ..writeByte(4)
      ..write(obj.unitPrice)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.lineTotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillLineItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
