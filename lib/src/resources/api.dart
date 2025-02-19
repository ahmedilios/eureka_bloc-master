import 'package:altair/src/models/auth/token.dart';
import 'package:dio/dio.dart';
import '../resources/interceptor.dart';

export 'dart:io' show HttpHeaders;

/// Interface que descreve uma API a ser utilizada.
abstract class EurekaApi<AuthModel extends Token> {
  /// API onde serão feitas as requisições
  Dio api;

  /// Dados de autenticação da API
  AuthModel authData;

  Future<Response<T>> get<T>(
    String url, {
    Options options,
  });

  Future<Response<T>> put<T>(
    String url, {
    dynamic data,
    Options options,
  });

  Future<Response<T>> post<T>(
    String url, {
    dynamic data,
    Options options,
  });

  Future<Response<T>> delete<T>(
    String url, {
    dynamic data,
    Options options,
  });

  Future<Response<T>> patch<T>(
    String url, {
    dynamic data,
    Options options,
  });

  void addHeader({String header, String value});

  void removeHeader({String header});

  /// Função que recebe um [DioError] e gera uma mensagem para o
  /// [RepositoryResponse].
  String handleError(DioError dioError);
}

/// API HTTP simples.
///
/// Implementa os métodos `get`, `put`, `post`, `delete` e `patch`.
/// Se nenhum interceptor for informado, adiciona um [BackupInterceptor].
///
/// Você deve sobrescrever essa API para aplicar sua própria configuração.
///
/// Exemplo de utilização:
/// ```
/// class Api extends SimpleApi {
///   Api.()
///     : super(
///         Dio(
///           BaseOptions(
///             baseUrl: 'http://localhost:3123/',
///             connectTimeout: 10000, // em ms
///             receiveTimeout: 10000, // em ms
///             followRedirects: true,
///           ),
///         ),
///       );
/// }
/// ```
abstract class SimpleApi<T extends Token> extends EurekaApi<T> {
  /// Inicializa uma API
  ///
  /// Caso não seja do interesse haver nenhum interceptor, nem mesmo o
  /// [BackupInterceptor] para o tratamento de políticas de backup, basta
  /// passar `null` no parâmetro opcional [interceptors].
  SimpleApi(
    Dio api, [
    List<Interceptor> interceptors = const [],
  ]) {
    this.api = api
      ..interceptors.addAll(
        interceptors == null
            ? []
            : interceptors.isEmpty ? [BackupInterceptor()] : interceptors,
      );
  }

  @override
  void addHeader({String header, String value}) {
    this.api.options.headers[header] = value;
  }

  @override
  void removeHeader({String header}) {
    this.api.options.headers.remove(header);
  }

  @override
  Future<Response<T>> get<T>(
    String url, {
    Options options,
  }) =>
      this.api.get(
            url,
            options: options,
          );

  @override
  Future<Response<T>> post<T>(
    String url, {
    dynamic data,
    Options options,
  }) =>
      this.api.post(
            url,
            data: data,
            options: options,
          );

  @override
  Future<Response<T>> delete<T>(
    String url, {
    dynamic data,
    Options options,
  }) =>
      this.api.delete(
            url,
            data: data,
            options: options,
          );

  @override
  Future<Response<T>> patch<T>(
    String url, {
    dynamic data,
    Options options,
  }) =>
      this.api.patch(
            url,
            data: data,
            options: options,
          );

  @override
  Future<Response<T>> put<T>(
    String url, {
    dynamic data,
    Options options,
  }) =>
      this.api.put(
            url,
            data: data,
            options: options,
          );

  @override
  String handleError(DioError dioError) => dioError.toString();
}
