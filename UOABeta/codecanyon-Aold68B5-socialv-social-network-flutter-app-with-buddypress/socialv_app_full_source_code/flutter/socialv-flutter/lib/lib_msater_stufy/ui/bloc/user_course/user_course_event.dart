import 'package:socialv/lib_msater_stufy/ui/screens/user_course/user_course.dart';
import 'package:meta/meta.dart';

@immutable
abstract class UserCourseEvent {}

class FetchEvent extends UserCourseEvent {
  final UserCourseScreenArgs userCourseScreenArgs;

  FetchEvent(this.userCourseScreenArgs);
}

class CacheCourseEvent extends UserCourseEvent {
  final UserCourseScreenArgs userCourseScreenArgs;

  CacheCourseEvent(this.userCourseScreenArgs);
}
