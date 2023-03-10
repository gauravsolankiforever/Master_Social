import 'package:socialv/lib_msater_stufy/data/models/course/CourcesResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class DetailProfileState {}

class InitialDetailProfileState extends DetailProfileState {}

class LoadedDetailProfileState extends DetailProfileState {
  final List<CoursesBean?>? courses;
  final bool isTeacher;

  LoadedDetailProfileState(this.courses, this.isTeacher);
}
