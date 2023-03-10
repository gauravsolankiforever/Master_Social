import 'package:socialv/lib_msater_stufy/data/models/LessonResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class QuizLessonState {}

class InitialQuizLessonState extends QuizLessonState {}

class CacheWarningQuizLessonState extends QuizLessonState {}

class LoadedQuizLessonState extends QuizLessonState {
  final LessonResponse quizResponse;

  LoadedQuizLessonState(this.quizResponse);
}
