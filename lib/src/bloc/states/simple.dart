import 'package:equatable/equatable.dart';
import '../../bloc/eureka.dart';
import '../../models/error.dart';
import '../../models/filter.dart';
import '../../models/model.dart';

/// Estado genérico para o BLoC de CRUD.
abstract class SimpleState extends EurekaState with EquatableMixin {}

/// Estado que indica que o BLoC não está inicializado.
class UninitializedState extends SimpleState {
  @override
  List get props => [];
}

/// Estado de conteúdo.
///
/// Este estado contém os dados de conteúdo que serão preservados entre os
/// sucessos e falhas do BLoC. Logo, estados que semanticamente possam carregar
/// conteúdo devem estender este estado.
class ContentState<S> extends SimpleState {
  /// Lista de modelos resumidos.
  final List<S> briefs;

  /// Indica se o limite de paginação foi atingido.
  final bool hasReachedMax;

  /// Conjunto de filtros aplicada para obter [briefs].
  final Set<Filter> filters;

  ContentState({
    this.briefs = const [],
    this.hasReachedMax = false,
    this.filters = const {},
  });

  @override
  List get props => [briefs, hasReachedMax, filters];
}

/// Estado que indica que o BLoC está carregando.
class LoadingState<S, D> extends ContentState {
  LoadingState({
    List<S> briefs,
    bool hasReachedMax,
    Set<Filter> filters,
  }) : super(
          briefs: briefs,
          hasReachedMax: hasReachedMax,
          filters: filters,
        );

  /// Construtor que permite criar um [LoadingState] a partir de um
  /// [ContentState] qualquer.
  factory LoadingState.overwrite(
    ContentState<S> state, {
    List<S> briefs,
    bool hasReachedMax,
    Set<Filter> filters,
  }) =>
      LoadingState<S, D>(
        briefs: briefs ?? state?.briefs,
        hasReachedMax: hasReachedMax ?? state?.hasReachedMax,
        filters: filters ?? state?.filters,
      );
}

/// Estado de conteúdo que indica que houve sucesso na operação do BLoC.
class SuccessState<S extends ShortModel, D extends DetailModel>
    extends ContentState<S> implements IEurekaSuccessState {
  /// Resultado das operações que manipulam um `DetailModel`.
  final D focused;

  SuccessState({
    this.focused,
    List<S> briefs,
    bool hasReachedMax,
    Set<Filter> filters,
  }) : super(
          briefs: briefs,
          hasReachedMax: hasReachedMax,
          filters: filters,
        );

  /// Construtor que permite criar um [SuccessState] a partir de um
  /// [ContentState] qualquer.
  factory SuccessState.overwrite(
    ContentState<S> state, {
    D focused,
    List<S> briefs,
    bool hasReachedMax,
    Set<Filter> filters,
  }) =>
      SuccessState<S, D>(
        focused: focused ??
            (state is SuccessState ? (state as SuccessState)?.focused : null),
        briefs: briefs ?? state?.briefs,
        hasReachedMax: hasReachedMax ?? state?.hasReachedMax,
        filters: filters ?? state?.filters,
      );
}

/// Estado de conteúdo que indica que houve falha na operação do BLoC.
class FailState<S extends ShortModel> extends ContentState<S>
    implements IEurekaFailState {
  /// Descreve a falha ocorrida na execução da operação.
  final ErrorModel error;

  FailState({
    this.error,
    List<S> briefs,
    bool hasReachedMax,
    Set<Filter> filters,
  }) : super(
          briefs: briefs,
          hasReachedMax: hasReachedMax,
          filters: filters,
        );

  /// Construtor que permite criar um [FailState] a partir de um [ContentState]
  /// qualquer.
  factory FailState.overwrite(
    ContentState<S> state, {
    ErrorModel error,
    List<S> briefs,
    bool hasReachedMax,
    Set<Filter> filters,
  }) =>
      FailState<S>(
        error: error,
        briefs: briefs ?? state?.briefs,
        hasReachedMax: hasReachedMax ?? state?.hasReachedMax,
        filters: filters ?? state?.filters,
      );
}
