import 'package:socialv/lib_msater_stufy/data/models/course/CourcesResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class FavoritesState {}

class InitialFavoritesState extends FavoritesState {}
class EmptyFavoritesState extends FavoritesState {}

class LoadedFavoritesState extends FavoritesState {
  final List<CoursesBean?> favoriteCourses;

  LoadedFavoritesState(this.favoriteCourses);
}

class ErrorFavoritesState extends FavoritesState {}
