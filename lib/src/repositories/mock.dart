import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../../altair.dart';
import '../models/filter.dart';
import '../models/model.dart';
import '../models/response.dart';
import '../resources/api.dart';

export '../models/filter.dart';
export '../models/response.dart';
export '../repositories/config.dart';

class MockRepository<M extends Model, S extends ShortModel,
    D extends DetailModel> extends SimpleRepository<S, D> {
  final Map<int, M> data;

  @override
  SimpleRepositoryConfig<S, D> get config => SimpleRepositoryConfig(
        modelUrl: () => 'mock',
        shortFromJson: null,
        detailFromJson: null,
        backupConfig: null,
      );

  @override
  EurekaApi get api => null;

  MockRepository({
    @required this.data,
  });

  @override
  Future<RepositoryResponse<List<S>>> find([
    Set<Filter> filters,
  ]) async {
    try {
      await Future.delayed(Duration(seconds: 2));

      return RepositoryResponse<List<S>>.successOnline(
        data: data.values.map<S>((s) => s as S).toList(),
      );
    } on DioError catch (error) {
      return RepositoryResponse.failure(
        message: "List error",
        statusCode: error?.response?.statusCode,
      );
    }
  }

  @override
  Future<RepositoryResponse<D>> findByShort(
    S model, [
    Set<Filter> filters,
  ]) =>
      this.findById(model.id, filters);

  @override
  Future<RepositoryResponse<D>> findByCacheKey(
    String cacheKey, [
    Set<Filter> filters,
  ]) =>
      throw UnimplementedError();

  @override
  Future<RepositoryResponse<D>> findById(
    dynamic id, [
    Set<Filter> filters,
  ]) async {
    try {
      await Future.delayed(Duration(seconds: 2));

      return RepositoryResponse<D>.successOnline(
        data: data[id] as D,
      );
    } on DioError catch (error) {
      return RepositoryResponse.failure(
        message: "Detail error",
        statusCode: error?.response?.statusCode,
      );
    }
  }

  @override
  Future<RepositoryResponse<D>> create(D model) async {
    try {
      data[model.id] = model as M;

      await Future.delayed(Duration(seconds: 2));

      return RepositoryResponse<D>.successOnline(
        data: model,
      );
    } on DioError catch (error) {
      return RepositoryResponse.failure(
        message: "Create error",
        statusCode: error?.response?.statusCode,
      );
    }
  }

  @override
  Future<RepositoryResponse<D>> delete(dynamic id) async {
    try {
      data.remove(id);

      await Future.delayed(Duration(seconds: 2));

      return RepositoryResponse<D>.successOnline(data: null);
    } on DioError catch (error) {
      return RepositoryResponse.failure(
        message: "Delete error",
        statusCode: error?.response?.statusCode,
      );
    }
  }

  @override
  Future<RepositoryResponse<D>> update(D model) async {
    try {
      data[model.id] = model as M;

      await Future.delayed(Duration(seconds: 2));

      return RepositoryResponse<D>.successOnline(
        data: model,
      );
    } on DioError catch (error) {
      return RepositoryResponse.failure(
        message: "Patch error",
        statusCode: error?.response?.statusCode,
      );
    }
  }
}
