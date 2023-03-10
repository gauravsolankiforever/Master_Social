import 'package:socialv/lib_msater_stufy/data/models/category.dart';
import 'package:socialv/lib_msater_stufy/data/models/course/CourcesResponse.dart';
import 'package:meta/meta.dart';
import '../../../data/models/course/CourcesResponse.dart';

@immutable
abstract class CategoryDetailState {}

class InitialCategoryDetailState extends CategoryDetailState {}

class LoadedCategoryDetailState extends CategoryDetailState {
  final List<Category> categoryList;
  final List<CoursesBean?> courses;

  LoadedCategoryDetailState(this.categoryList, this.courses);
}

class ErrorCategoryDetailState extends CategoryDetailState {
  final int categoryId;

  ErrorCategoryDetailState(this.categoryId);
}
