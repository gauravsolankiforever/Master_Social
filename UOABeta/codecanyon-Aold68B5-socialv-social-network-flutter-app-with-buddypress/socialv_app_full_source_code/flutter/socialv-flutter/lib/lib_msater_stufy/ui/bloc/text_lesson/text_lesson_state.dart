import 'package:socialv/lib_msater_stufy/data/models/LessonResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TextLessonState {}

class InitialTextLessonState extends TextLessonState {}

class CacheWarningLessonState extends TextLessonState {}

class LoadedTextLessonState extends TextLessonState {
  final LessonResponse lessonResponse;

  LoadedTextLessonState(this.lessonResponse);
}