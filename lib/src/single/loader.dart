import 'package:altair/altair.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Classe base do estado do BLoC de carregamento avulso.
class DataLoaderState<T> extends Equatable {
  @override
  List get props => [];
}

class LoaderInitial<T> extends DataLoaderState<T> {}

class LoaderLoading<T> extends DataLoaderState<T> {}

class LoaderFailure<T> extends DataLoaderState<T> {
  final String error;

  @override
  List get props => [error];

  LoaderFailure({
    this.error,
  });
}

class LoaderSuccess<T> extends DataLoaderState<T> {
  final T model;

  @override
  List get props => [model];

  LoaderSuccess({
    this.model,
  });
}

/// Classe base do evento do BLoC de carregamento avulso.
class DataLoaderEvent<T, P> extends Equatable {
  @override
  List get props => [];
}

class LoaderLoad<T, P> extends DataLoaderEvent<T, P> {
  final P params;

  @override
  List get props => [params];

  LoaderLoad({
    this.params,
  });
}

/// Interface da função de carregamento.
abstract class ILoadRepository<T, P> {
  Future<RepositoryResponse<T>> load(P params);
}

/// Interface da função de carregamento.
class DataLoaderBloc<T, P, R extends ILoadRepository<T, P>>
    extends Bloc<DataLoaderEvent<T, P>, DataLoaderState<T>> {
  final R repository;

  DataLoaderBloc({
    @required this.repository,
  }) : assert(repository != null);

  @override
  DataLoaderState<T> get initialState => LoaderInitial<T>();

  @override
  Stream<DataLoaderState<T>> mapEventToState(
    DataLoaderEvent<T, P> event,
  ) async* {
    if (event is LoaderLoad<T, P>) {
      yield LoaderLoading<T>();

      final response = await repository.load(event.params);

      if (response.isSuccessful) {
        yield LoaderSuccess<T>(model: response.data);
      } else {
        yield LoaderFailure<T>(error: response.error.message);
      }
    }
  }
}
