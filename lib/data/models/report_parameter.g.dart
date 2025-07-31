// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_parameter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportParameterAdapter extends TypeAdapter<ReportParameter> {
  @override
  final int typeId = 1;

  @override
  ReportParameter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportParameter(
      name: fields[0] as String,
      value: fields[1] as String,
      normalRange: fields[2] as String,
      status: fields[3] as ParameterStatus,
      aiSummary: fields[4] as String,
      units: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReportParameter obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.normalRange)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.aiSummary)
      ..writeByte(5)
      ..write(obj.units);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportParameterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ParameterStatusAdapter extends TypeAdapter<ParameterStatus> {
  @override
  final int typeId = 2;

  @override
  ParameterStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ParameterStatus.low;
      case 1:
        return ParameterStatus.normal;
      case 2:
        return ParameterStatus.high;
      case 3:
        return ParameterStatus.unknown;
      default:
        return ParameterStatus.low;
    }
  }

  @override
  void write(BinaryWriter writer, ParameterStatus obj) {
    switch (obj) {
      case ParameterStatus.low:
        writer.writeByte(0);
        break;
      case ParameterStatus.normal:
        writer.writeByte(1);
        break;
      case ParameterStatus.high:
        writer.writeByte(2);
        break;
      case ParameterStatus.unknown:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParameterStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
