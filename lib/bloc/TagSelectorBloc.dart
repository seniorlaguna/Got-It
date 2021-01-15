import 'package:bloc/bloc.dart';
import 'package:got_it/data/Repository.dart';

class TagSelectorBloc extends Bloc<Set<String>, Set<String>> {
  final Repository _repository;

  TagSelectorBloc(this._repository);

  @override
  Set<String> get initialState => {};

  @override
  Stream<Set<String>> mapEventToState(Set<String> event) async* {
    yield event;
  }
}
