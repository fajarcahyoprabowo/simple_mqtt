// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageObjectAdapter extends TypeAdapter<MessageObject> {
  @override
  final int typeId = 1;

  @override
  MessageObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageObject(
      topic: fields[0] as String,
      message: fields[1] as String,
      qos: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MessageObject obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.topic)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.qos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
