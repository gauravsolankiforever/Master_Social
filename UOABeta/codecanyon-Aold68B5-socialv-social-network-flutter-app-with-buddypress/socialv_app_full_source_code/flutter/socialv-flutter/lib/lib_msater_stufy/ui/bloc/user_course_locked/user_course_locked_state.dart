import 'package:socialv/lib_msater_stufy/data/models/course/CourseDetailResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class UserCourseLockedState {}

class InitialUserCourseLockedState extends UserCourseLockedState {}

class LoadedUserCourseLockedState extends UserCourseLockedState {
  final CourseDetailResponse courseDetailResponse;

  LoadedUserCourseLockedState(this.courseDetailResponse);
}
