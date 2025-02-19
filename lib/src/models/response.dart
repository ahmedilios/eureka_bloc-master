import "package:meta/meta.dart";

import '../models/error.dart';

/// Resposta do repositório.
///
/// Encapsula todos os dados e metadados que podem ser retornados a partir de
/// uma chamada a um método de um repositório.
///
/// Define uma interface padrão entre BLoCs e Repositórios.
///
/// **Todos** os métodos de repositório **devem** retornar um
/// [RepositoryResponse].
class RepositoryResponse<T> {
  /// Mensagem informativa, caso tenha ocorrido um erro.
  final String message;

  /// Indica se houve sucesso na requisição.
  final bool isSuccessful;

  /// Indica se o dado retornado é proveniente da API ou do sistema de backup.
  final bool isOnline;

  /// Dado retornado pela requisição.
  final T data;

  /// Código HTTP de resposta, caso tenha ocorrido um erro.
  final int statusCode;

  /// Dados de paginação referente ao dado retornado.
  final PageData pageData;

  /// Indica se o erro ocorreu por uma não-autorização da API.
  bool get isUnauthorized => statusCode == 401;

  /// Retorna um [ErrorModel] a partir dos metadados da requisição.
  ErrorModel get error => ErrorModel(
        message: this.message,
        isUnauthorized: this.isUnauthorized,
      );

  /// Construtor para caso tenha ocorrido êxito na requisição via API.
  RepositoryResponse.successOnline({
    this.isOnline = true,
    @required this.data,
    this.message,
    this.statusCode,
    this.pageData,
  }) : isSuccessful = true;

  /// Construtor para caso tenha ocorrido êxito na requisição, mas sem conexão
  /// com a API.
  RepositoryResponse.successOffline({
    this.isOnline = false,
    @required this.data,
    this.message,
    this.statusCode,
    this.pageData,
  }) : isSuccessful = true;

  /// Construtor para caso tenha ocorrido falha na requisição.
  RepositoryResponse.failure({
    this.isOnline,
    this.data,
    this.statusCode,
    this.pageData,
    @required this.message,
  }) : isSuccessful = false;
}

/// Dados de paginação.
class PageData {
  /// Página atual.
  final int currentPage;

  /// Quantidade máxima de páginas.
  final int maxPages;

  /// Indica a se a quantidade máxima de páginas já foi atingida.
  bool get hasReachedMax => currentPage == maxPages;

  PageData({
    this.currentPage,
    this.maxPages,
  });
}
