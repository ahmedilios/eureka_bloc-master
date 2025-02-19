import 'package:altair/altair.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Classe base do estado do BLoC de post avulso.
class DataPosterState<T, U> extends Equatable {
  @override
  List get props => [];
}

class PosterInitial<T, U> extends DataPosterState<T, U> {}

class PosterLoading<T, U> extends DataPosterState<T, U> {}

class PosterFailure<T, U> extends DataPosterState<T, U> {
  final String error;

  @override
  List get props => [error];

  PosterFailure({
    this.error,
  });
}

class PosterSuccess<T, U> extends DataPosterState<T, U> {
  final U extra;

  @override
  List get props => [extra];

  PosterSuccess({
    this.extra,
  });
}

/// Classe base do evento do BLoC de carregamento avulso.
class DataPosterEvent<T> extends Equatable {
  @override
  List get props => [];
}

class PosterPost<T> extends DataPosterEvent<T> {
  final T data;

  @override
  List get props => [data];

  PosterPost({
    this.data,
  });
}

/// Interface da função de carregamento.
abstract class IPostRepository<T, U> {
  Future<RepositoryResponse<U>> post(T data);
}

/// Interface da função de carregamento.
class DataPosterBloc<T, U, R extends IPostRepository<T, U>>
    extends Bloc<DataPosterEvent<T>, DataPosterState<T, U>> {
  final R repository;

  DataPosterBloc({
    @required this.repository,
  }) : assert(repository != null);

  @override
  DataPosterState<T, U> get initialState => PosterInitial<T, U>();

  @override
  Stream<DataPosterState<T, U>> mapEventToState(
    DataPosterEvent<T> event,
  ) async* {
    if (event is PosterPost<T>) {
      yield PosterLoading<T, U>();

      final response = await repository.post(event.data);

      if (response.isSuccessful) {
        yield PosterSuccess<T, U>(extra: response.data);
      } else {
        yield PosterFailure<T, U>(error: response.error.message);
      }
    }
  }
}
