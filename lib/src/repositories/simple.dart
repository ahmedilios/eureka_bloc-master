import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/filter.dart';
import '../models/model.dart';
import '../models/response.dart';
import '../repositories/config.dart';
import '../repositories/repository.dart';
import '../resources/api.dart';

export '../models/filter.dart';
export '../models/response.dart';
export '../repositories/config.dart';

/// Repositório simples de CRUD.
///
/// Implementa as funções básicas de CRUD nos métodos `find`, `create`,
/// `findById`, `delete` e `update` para um modelo de variações [ShortModel] e
/// [DetailModel].
abstract class SimpleRepository<S extends ShortModel, D extends DetailModel>
    extends EurekaRepository {
  /// Configuração do repositório.
  SimpleRepositoryConfig<S, D> get config;

  /// API para onde são feitas as requisições.
  EurekaApi get api;

  /// Retorna uma lista de modelos resumidos.
  ///
  /// Faz uma requisição `GET` no endpoint `config.endpointUrl` com os [filters],
  /// adicionando a política de backup selecionada no `config.backupConfig`
  /// para o método `find`.
  Future<RepositoryResponse<List<S>>> find([
    Set<Filter> filters,
  ]) async {
    try {
      final url = this.config.endpointUrl();
      final encodedFilters = filters?.map((f) => f.encoded)?.join('&') ?? '';
      final response = await api.get(
        [url, encodedFilters].join('?'),
        options: this.config.backupConfig?.find?.options,
      );
      final jsonObject = response.data is! List && config.rootField != null
          ? config.rootField(response)
          : response.data;
      final data = (jsonObject ?? [])
          .map<S>((json) => this.config.shortFromJson(json))
          .toList();
      return RepositoryResponse<List<S>>.successOnline(data: data);
    } on DioError catch (error) {
      debugPrint(error?.toString());
      debugPrint(error?.response?.toString());
      return RepositoryResponse.failure(
        message: api.handleError(error),
        statusCode: error?.response?.statusCode,
      );
    } catch (error) {
      debugPrint(error?.toString());
      return RepositoryResponse.failure(message: error.toString());
    }
  }

  /// Busca o modelo detalhado com base no [shortModel].
  ///
  /// Aplica o [findById] usando a propriedade `id` do [shortModel],
  /// reencaminhando os [filters].
  Future<RepositoryResponse<D>> findByShort(
    S shortModel, [
    Set<Filter> filters,
  ]) =>
      this.findById(shortModel.id, filters);

  /// Busca o modelo detalhado no armazenamento.
  ///
  /// Recupera o [DetailModel] pelo [cacheKey] informado.
  ///
  /// Retorna `null` se não houver sucesso.
  Future<RepositoryResponse<D>> findByCacheKey(
    String cacheKey, [
    Set<Filter> filters,
  ]) =>
      throw UnimplementedError();

  /// Retorna um modelo detalhado com base no [id].
  ///
  /// Faz uma requisição `GET` no endpoint `config.endpointUrl/[id]` com os
  /// [filters], adicionando a política de backup selecionada no
  /// `config.backupConfig` para o método `findById`.
  Future<RepositoryResponse<D>> findById(
    dynamic id, [
    Set<Filter> filters,
  ]) async {
    try {
      final baseUrl = this.config.endpointUrl();
      final url = "$baseUrl/${id.toString()}";
      final encodedFilters = filters?.map((f) => f.encoded)?.join('&') ?? '';
      final response = await api.get(
        [url, encodedFilters].join('?'),
        options: this.config.backupConfig?.findById?.options,
      );
      return RepositoryResponse<D>.successOnline(
        data: this.config.detailFromJson(response.data),
      );
    } on DioError catch (error) {
      debugPrint(error?.toString());
      debugPrint(error?.response?.toString());
      return RepositoryResponse.failure(
        message: api.handleError(error),
        statusCode: error?.response?.statusCode,
      );
    } catch (error) {
      debugPrint(error?.toString());
      return RepositoryResponse.failure(message: error.toString());
    }
  }

  /// Persiste o [detailModel] na API.
  ///
  /// Faz uma requisição `POST` no endpoint `config.endpointUrl`, retornando a
  /// instância persistida em caso de sucesso.
  Future<RepositoryResponse<D>> create(D detailModel) async {
    try {
      final url = this.config.endpointUrl();
      final response = await api.post(
        url,
        data: detailModel.toJson(),
      );
      return RepositoryResponse<D>.successOnline(
        data: this.config.detailFromJson(response.data),
      );
    } on DioError catch (error) {
      debugPrint(error?.toString());
      debugPrint(error?.response?.toString());
      return RepositoryResponse.failure(
        message: api.handleError(error),
        statusCode: error?.response?.statusCode,
      );
    }
  }

  /// Remove um modelo da API, usando a propriedade `id`.
  ///
  /// Faz uma requisição `DELETE` no endpoint `config.endpointUrl/[id]`.
  Future<RepositoryResponse> delete(dynamic id) async {
    try {
      final baseUrl = this.config.endpointUrl();
      final url = "$baseUrl/${id.toString()}";
      await api.delete(url);
      return RepositoryResponse.successOnline(data: null);
    } on DioError catch (error) {
      debugPrint(error?.toString());
      debugPrint(error?.response?.toString());
      return RepositoryResponse.failure(
        message: api.handleError(error),
        statusCode: error?.response?.statusCode,
      );
    } catch (error) {
      debugPrint(error?.toString());
      return RepositoryResponse.failure(message: error.toString());
    }
  }

  /// Atualiza o [detailModel] da API, usando a propriedade `id`.
  ///
  /// Faz uma requisição `PATCH` no endpoint `config.endpointUrl/[id]`, retornando
  /// a instância atualizada em caso de sucesso.
  Future<RepositoryResponse<D>> update(D detailModel) async {
    try {
      final baseUrl = this.config.endpointUrl();
      final url = "$baseUrl/${detailModel?.id}";
      final response = await api.patch(
        url,
        data: detailModel.toJson(),
      );
      return RepositoryResponse<D>.successOnline(
        data: this.config.detailFromJson(response.data),
      );
    } on DioError catch (error) {
      debugPrint(error?.toString());
      debugPrint(error?.response?.toString());
      return RepositoryResponse.failure(
        message: api.handleError(error),
        statusCode: error?.response?.statusCode,
      );
    } catch (error) {
      debugPrint(error?.toString());
      return RepositoryResponse.failure(message: error.toString());
    }
  }
}
