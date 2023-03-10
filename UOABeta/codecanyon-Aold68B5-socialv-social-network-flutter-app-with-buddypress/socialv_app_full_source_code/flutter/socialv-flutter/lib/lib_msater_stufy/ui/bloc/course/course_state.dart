import 'package:socialv/lib_msater_stufy/data/models/ReviewResponse.dart';
import 'package:socialv/lib_msater_stufy/data/models/course/CourseDetailResponse.dart';
import 'package:socialv/lib_msater_stufy/data/models/purchase/UserPlansResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CourseState {}

class InitialCourseState extends CourseState {}

class OpenPurchaseState extends CourseState {
  final String url;

  OpenPurchaseState(this.url);
}

class LoadedCourseState extends CourseState {
  final CourseDetailResponse courseDetailResponse;
  final ReviewResponse reviewResponse;
  final UserPlansResponse? userPlans;

  LoadedCourseState(this.courseDetailResponse, this.reviewResponse, {this.userPlans});
}

class OpenPurchaseDialogState extends CourseState {
  final TokenAuthToCourse tokenAuthToCourse;

  OpenPurchaseDialogState(this.tokenAuthToCourse);
}

class ErrorCourseState extends CourseState {}
