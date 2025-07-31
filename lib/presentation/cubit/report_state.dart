// lib/presentation/cubit/report_state.dart
import 'package:bloodsage/data/models/report_parameter.dart';
import 'package:equatable/equatable.dart';

abstract class ReportState extends Equatable {
  const ReportState();
  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportSuccess extends ReportState {
  // ✨ This now holds the list of parameters directly
  final List<ReportParameter> parameters;
  const ReportSuccess(this.parameters);
  @override
  List<Object> get props => [parameters];
}

class ReportFailure extends ReportState {
  final String error;
  const ReportFailure(this.error);
  @override
  List<Object> get props => [error];
}
