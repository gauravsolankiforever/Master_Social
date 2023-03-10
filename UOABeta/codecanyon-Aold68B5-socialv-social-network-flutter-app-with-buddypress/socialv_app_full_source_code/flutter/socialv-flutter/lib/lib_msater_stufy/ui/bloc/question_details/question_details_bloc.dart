
import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:socialv/lib_msater_stufy/data/models/QuestionAddResponse.dart';
import 'package:socialv/lib_msater_stufy/data/repository/questions_repository.dart';

import './bloc.dart';

@provide
class QuestionDetailsBloc extends Bloc<QuestionDetailsEvent, QuestionDetailsState> {
  final QuestionsRepository _questionsRepository;

  QuestionDetailsState get initialState => InitialQuestionDetailsState();

  QuestionDetailsBloc(this._questionsRepository) : super(InitialQuestionDetailsState()) {
    on<FetchEvent>((event, emit) async {
      emit(LoadedQuestionDetailsState());
    });

    on<QuestionAddEvent>((event, emit) async {
      try {
        emit(ReplyAddingState());
        QuestionAddResponse addAnswer = await _questionsRepository.addQuestion(event.lessonId, event.comment, event.parent);
        emit(ReplyAddedState(addAnswer));
      } catch (error) {
        print(error);
      }

      emit(LoadedQuestionDetailsState());
    });
  }
}
