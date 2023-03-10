import 'package:socialv/lib_msater_stufy/data/models/AssignmentResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AssignmentState {}

class InitialAssignmentState extends AssignmentState {}

class LoadedAssignmentState extends AssignmentState {
    final AssignmentResponse assignmentResponse;

    LoadedAssignmentState(this.assignmentResponse);
}

class ErrorAssignmentState extends AssignmentState {}

class CacheWarningAssignmentState extends AssignmentState {}