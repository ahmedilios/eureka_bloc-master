import 'package:altair/altair.dart';
import 'package:meta/meta.dart';

import '../bloc/eureka.dart';
import 'events/simple.dart';
import 'states/simple.dart';
import '../models/filter_pagination.dart';
import '../models/model.dart';
import '../models/response.dart';
import '../repositories/simple.dart';

export 'events/simple.dart';
export 'states/simple.dart';

/// BLoC básico de CRUD
///
/// Este BLoC fornece a estrutura básica com implementação padrão do método
/// `load` para o modelo resumido [S], e implementação dos métodos `select`,
/// `create`, `update` e `delete` para o modelo detalhado [D], através de um
/// repositório [R].
///
/// O BLoC também suporta paginação do recurso do método `load`, recuperando os
/// próximos recursos paginados a partir do evento `next`.
///
/// Assim, o fluxo de tratamento dos eventos já contempla os casos-base para os
/// modelos [ShortModel] e [DetailModel] seguindo a implementação dos métodos
/// de um [SimpleRepository].
///
/// Os atributos entre estados são cumulativos, mantendo a implementação com o
/// [ContentState]. Assim, estados de erro terão todas as propriedades de seus
/// antecessores, acrescido do erro [ErrorModel] obrigatório.
///
/// Exemplo de utilização:
/// ```
/// class PersonBloc extends SimpleBloc<PersonShort, PersonDetail,
/// PersonRepository>{
///  @override
///  final PersonRepository repository;
///  PersonBloc(this.repository) : super(repository);
///
///  @override
///  Stream<SimpleState> mapEventToState(SimpleEvent event) async* {
///    yield* super.mapEventToState(event);
///    // Implement mapEventToState for other events
///  }
/// }
/// ```
/// Quaisquer outros eventos podem ser tratados após a chamada ao
/// `super.mapEventToState`.
abstract class SimpleBloc<S extends ShortModel, D extends DetailModel,
        R extends SimpleRepository<S, D>>
    extends EurekaBloc<SimpleEvent, SimpleState> {
  /// Repositório para o qual o BLoC fará as requisições.
  R get repository;

  /// Último estado de conteúdo registrado, no início do processamento.
  ContentState<S> oldState;

  /// Método que registra o estado atual no estado de conteúdo [oldState].
  void saveCurrentState() {
    if (this.state is ContentState) this.oldState = this.state;
  }

  @override
  SimpleState get initialState => UninitializedState();

  @override
  @mustCallSuper
  Stream<SimpleState> mapEventToState(SimpleEvent event) async* {
    this.saveCurrentState();
    try {
      if (event is LoadEvent) yield* _loadEvent(event);
      if (event is SelectEvent) yield* _selectEvent(event);
      if (event is CreateEvent) yield* _createEvent(event);
      if (event is DeleteEvent) yield* _deleteEvent(event);
      if (event is UpdateEvent) yield* _updateEvent(event);
      if (event is NextEvent) yield* _nextEvent(event);
    } catch (e) {
      print(e);
      yield FailState(
        error: ErrorModel(message: e.toString()),
      );
    }
  }

  Stream<SimpleState> _handleFocused(RepositoryResponse response) async* {
    if (response.isSuccessful) {
      yield SuccessState<S, D>.overwrite(
        this.oldState,
        focused: response.data as D,
      );
    } else {
      yield* this._sendFail(response);
    }
  }

  Stream<SimpleState> _updateEvent(UpdateEvent<D> event) async* {
    yield LoadingState.overwrite(oldState);

    final response = await repository.update(event.detailed);

    yield* this._handleFocused(response);
  }

  Stream<SimpleState> _deleteEvent(DeleteEvent event) async* {
    yield LoadingState.overwrite(oldState);

    final response = await repository.delete(event.model?.id ?? event.id);

    yield* this._handleFocused(response);
  }

  Stream<SimpleState> _createEvent(CreateEvent<D> event) async* {
    yield LoadingState.overwrite(oldState);

    final response = await repository.create(event.detailed);

    yield* this._handleFocused(response);
  }

  Stream<SimpleState> _selectEvent(SelectEvent event) async* {
    yield LoadingState.overwrite(oldState);

    RepositoryResponse<D> response = RepositoryResponse.failure(
      message: null,
    );

    if (event.model != null && event.model is D) {
      response = RepositoryResponse.successOffline(
        data: (event.model as D),
      );
    } else if (event.model != null && event.model is S) {
      response = await repository.findByShort(
        (event.model as S),
        event.filters,
      );
    } else if (event.id != null) {
      response = await repository.findById(
        event.id,
        event.filters,
      );
    } else if (event.cacheKey != null) {
      response = await repository.findByCacheKey(
        event.cacheKey,
        event.filters,
      );
    }

    if (response.isSuccessful) {
      yield SuccessState<S, D>.overwrite(
        this.oldState,
        filters: event.filters,
        focused: response.data,
      );
    } else {
      yield* this._sendFail(response, event.filters);
    }
  }

  Stream<SimpleState> _loadEvent(LoadEvent event) async* {
    yield LoadingState.overwrite(
      oldState,
      filters: event.filters,
    );

    Set<Filter> filters = event.filters ?? {};

    if (event.pageOptions?.paginated ?? false) {
      filters = _handlePagination(
        filters,
        isNext: false,
        limitPerRequest: event.pageOptions.limitPerRequest,
      );
    }

    yield* _loadByFilters(filters);
  }

  Stream<SimpleState> _nextEvent(NextEvent event) async* {
    yield LoadingState.overwrite(oldState);

    Set<Filter> filters = oldState?.filters ?? {};

    filters = _handlePagination(filters);

    yield* _loadByFilters(filters, isNext: true);
  }

  Stream<SimpleState> _loadByFilters(
    Set<Filter> filters, {
    bool isNext = false,
  }) async* {
    List<S> data = oldState?.briefs ?? [];

    final response = await repository.find(filters);

    if (response.isSuccessful) {
      if (isNext) {
        data.addAll(response.data);
      } else {
        data = response.data;
      }
      yield SuccessState<S, D>.overwrite(
        this.oldState,
        briefs: data,
        filters: filters,
        hasReachedMax: response.data?.isEmpty ?? true,
      );
    } else {
      yield* this._sendFail(response, filters);
    }
  }

  Set<Filter> _handlePagination(
    Set<Filter> filters, {
    isNext = true,
    limitPerRequest = 25,
  }) {
    Set<Filter> auxFilters = Set.from(filters);
    final paginationFilter = auxFilters.firstWhere(
      (element) => element is FilterPagination,
      orElse: () => null,
    );
    if (paginationFilter == null) {
      auxFilters.add(FilterPagination.start(limitPerRequest));
    } else {
      auxFilters.removeWhere((element) => element is FilterPagination);
      if (isNext) auxFilters.add(FilterPagination.next(paginationFilter));
    }
    return auxFilters;
  }

  Stream<SimpleState> _sendFail(
    RepositoryResponse response, [
    Set<Filter> filters,
  ]) async* {
    yield FailState<S>.overwrite(
      this.oldState,
      error: response.error,
      filters: filters,
    );
  }
}
