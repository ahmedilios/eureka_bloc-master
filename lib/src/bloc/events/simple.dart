import 'package:equatable/equatable.dart';
import '../eureka.dart';
import '../../models/filter.dart';
import '../../models/model.dart';
import '../../resources/page_options.dart';
import 'package:flutter/foundation.dart';

/// Evento genérico para o BLoC de CRUD.
abstract class SimpleEvent extends EurekaEvent with EquatableMixin {}

/// Evento para executar a operação de `load`.
///
/// Executará a operação pelo método `find` do repositório.
class LoadEvent extends SimpleEvent {
  /// Conjunto opcional de filtros, que será processado na requisição.
  final Set<Filter> filters;

  /// Classe para gerenciar as opções de paginamento
  final PageOptions pageOptions;

  LoadEvent({
    this.filters = const {},
    this.pageOptions = const PageOptions(paginated: false),
  });

  @override
  List get props => [filters];
}

/// Evento para buscar os próximos registros de uma paginação
class NextEvent extends SimpleEvent {
  /// Conjunto opcional de filtros, que será processado na requisição.
  final Set<Filter> filters;

  NextEvent({
    this.filters = const {},
  });

  @override
  List get props => [filters];
}

/// Evento para executar a operação de `select`.
class SelectEvent<M extends Model> extends SimpleEvent {
  /// Modelo base para seleção, se o evento for construído a partir do método
  /// `SelectEvent.byModel`.
  final M model;

  /// Identificador para seleção, se o evento for construído a partir do método
  /// `SelectEvent.byId`.
  final dynamic id;

  /// Chave de registro para seleção, se o evento for construído a partir do
  /// método `SelectEvent.byCacheKey`.
  final String cacheKey;

  /// Lista opcional de filtros, que será processado na requisição.
  final Set<Filter> filters;

  @override
  List get props => [model, id, cacheKey, filters];

  SelectEvent._({
    this.model,
    this.id,
    this.cacheKey,
    this.filters,
  });

  /// Detalha um modelo com base em outro [model], do mesmo tipo.
  ///
  /// Se o modelo já for detalhado (`M is DetailModel`), apenas o encaminha
  /// para o foco no estado de sucesso. Caso contrário, executará a operação
  /// pelo método `findByShort` do repositório.
  factory SelectEvent.byModel(M model, [Set<Filter> filters]) => SelectEvent._(
        model: model,
        filters: filters,
      );

  /// Detalha um modelo com base no próprio [id].
  ///
  /// Executará a operação pelo método `findById` do repositório.
  factory SelectEvent.byId(dynamic id, [Set<Filter> filters]) => SelectEvent._(
        id: id,
        filters: filters,
      );

  /// Detalha um modelo com base na chave [cacheKey].
  ///
  /// Assume que o modelo detalhado esperado esteja salvo em cache.
  /// Executará a operação pelo método `findByCacheKey` do repositório.
  factory SelectEvent.byCacheKey(String cacheKey, [Set<Filter> filters]) =>
      SelectEvent._(
        cacheKey: cacheKey,
        filters: filters,
      );
}

/// Evento para executar a operação de `create`.
class CreateEvent<D extends DetailModel> extends SimpleEvent {
  /// Modelo a ser criado, submetido ao método `create` do repositório.
  final D detailed;

  CreateEvent({
    @required this.detailed,
  });

  @override
  List get props => [detailed];
}

/// Evento para executar a operação de `delete`.
class DeleteEvent<M extends Model> extends SimpleEvent {
  /// Modelo a ser excluído, se o evento for construído a partir do método
  /// `DeleteEvent.byModel`.
  final M model;

  /// Identificador do modelo a ser excluído, se o evento for construído a
  /// partir do método `DeleteEvent.byId`.
  final dynamic id;

  DeleteEvent._({
    this.model,
    this.id,
  });

  /// Exclui o [model].
  ///
  /// Executará a operação  pelo método `delete` do repositório, usando a
  /// propriedade `id` do [model].
  factory DeleteEvent.byModel(M model) => DeleteEvent._(model: model);

  /// Exclui um modelo com base no próprio [id].
  ///
  /// Executará a operação com o [id] pelo método `delete` do repositório.
  factory DeleteEvent.byId(dynamic id) => DeleteEvent._(id: id);

  @override
  List get props => [model, id];
}

/// Evento para executar a operação de `update`.
class UpdateEvent<D extends DetailModel> extends SimpleEvent {
  /// Modelo atualizado, submetido ao método `update` do repositório.
  final D detailed;

  UpdateEvent({
    @required this.detailed,
  });

  @override
  List get props => [detailed];
}
