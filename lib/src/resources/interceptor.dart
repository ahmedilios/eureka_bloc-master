import 'dart:io';

import 'package:dio/dio.dart';
import '../repositories/policy.dart';

/// Interceptador para backup.
///
/// Ao interceptar uma resposta ou um erro, verifica se a requisição de origem
/// possui uma [BackupPolicy] nos extras e, caso afirmativo, a executa para
/// armazenar ou recuperar os dados.
///
/// Por padrão, o método [onError] solicita recuperação dos dados apenas em
/// casos de *timeout* ou falha de conexão.
///
/// Você pode estender essa classe para modificar condições de invocação das
/// políticas nos métodos [onResponse], [onRequest] e [onError]. Caso você
/// deseje um interceptador para outros fins, estenda diretamente da classe
/// [Interceptor].
class BackupInterceptor extends Interceptor {
  @override
  Future onResponse(Response response) async {
    final policy =
        response.request.extra[BackupPolicy.identifier] as BackupPolicy;
    await policy?.save(response);
    return response;
  }

  @override
  Future onError(DioError e) async {
    if (e.type == DioErrorType.CONNECT_TIMEOUT ||
        e.type == DioErrorType.RECEIVE_TIMEOUT ||
        (e.type == DioErrorType.DEFAULT && e.error is SocketException)) {
      final policy = e.request.extra[BackupPolicy.identifier] as BackupPolicy;
      final response = await policy?.retrieve(e.request);
      if (response != null) return response;
    }
    return e;
  }
}
