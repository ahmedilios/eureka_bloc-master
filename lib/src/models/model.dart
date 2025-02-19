/// Modelo genérico para manipulação dos Repositories.
abstract class Model {
  /// Identificação única do modelo.
  dynamic get id;

  /// Retorna uma representação em `json` do modelo.
  Map<String, dynamic> toJson();
}

/// Modelo resumido genérico.
///
/// Deve carregar apenas informações necessárias para a exibição na listagem.
///
/// Em alguns casos, pode ser o próprio [DetailModel].
abstract class ShortModel extends Model {}

/// Modelo detalhado genérico.
///
/// Deve carregar todas informações referentes ao modelo, sendo necessárias
/// para a exibição nos detalhes.
///
/// Em alguns casos, pode ser o próprio [ShortModel].
abstract class DetailModel extends Model {}
