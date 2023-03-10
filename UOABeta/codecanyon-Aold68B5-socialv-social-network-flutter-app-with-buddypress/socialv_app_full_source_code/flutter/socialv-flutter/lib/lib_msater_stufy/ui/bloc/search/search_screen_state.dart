import 'package:socialv/lib_msater_stufy/data/models/course/CourcesResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SearchScreenState {}

class InitialSearchScreenState extends SearchScreenState {}

class ErrorSearchScreenState extends SearchScreenState {}

class LoadedSearchScreenState extends SearchScreenState {
  final List<CoursesBean?> newCourses;
  final List<String?> popularSearch;

  LoadedSearchScreenState(this.newCourses, this.popularSearch);
}

class ResultsSearchScreenState extends SearchScreenState {
  final List<CoursesBean> courses;

  ResultsSearchScreenState(this.courses);
}
