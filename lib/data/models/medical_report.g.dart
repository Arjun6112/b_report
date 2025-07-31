// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicalReportAdapter extends TypeAdapter<MedicalReport> {
  @override
  final int typeId = 0;

  @override
  MedicalReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalReport(
      id: fields[0] as String,
      reportDate: fields[1] as DateTime,
      parameters: (fields[3] as List).cast<ReportParameter>(),
      labName: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalReport obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reportDate)
      ..writeByte(2)
      ..write(obj.labName)
      ..writeByte(3)
      ..write(obj.parameters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
