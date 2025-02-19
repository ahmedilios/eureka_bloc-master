import '../models/auth/token.dart';
import '../models/model.dart';
import '../repositories/policies/counter.dart';
import '../repositories/policies/simple.dart';
import '../repositories/policy.dart';
import 'package:flutter/widgets.dart';

abstract class RepositoryConfig {
  /// Função que gera o endpoint do modelo.
  ///
  /// Você pode utilizar essa função para incluir, no endpoint, outras
  /// variáveis ou, simplesmente, retornar uma `String` estática.
  final String Function() endpointUrl;

  RepositoryConfig({
    this.endpointUrl,
  });
}

/// Configuração do Repositório.
///
/// Define o comportamento de um repositório, encapsulando informações sobre
/// como executar as requisições e sobre tratamento e processamento dos dados.
///
/// Exemplo de uso:
/// ```
/// final config = RepositoryConfig(
///     modelUrl: '/people',
///     shortFromJson: (json) => PersonShort.fromJson(json),
///     detailFromJson: (json) => PersonDetailed.fromJson(json),
///     backupConfig: BackupConfig.all,
///   );
/// ```
/// O endpoint raiz do modelo é a base para todas as requisições do repositório.
class SimpleRepositoryConfig<S extends ShortModel, D extends DetailModel>
    extends RepositoryConfig {
  /// Endpoint raiz do modelo.

  /// Função que gera um [ShortModel] a partir de um [Map].
  ///
  /// Define como o processamento do [ShortModel] acontecerá quando o
  /// repositório receber um `json`.
  final S Function(Map<String, dynamic>) shortFromJson;

  /// Função que gera um [DetailModel] a partir de um [Map].
  ///
  /// Define como o processamento do [DetailModel] acontecerá quando o
  /// repositório receber um `json`.
  final D Function(Map<String, dynamic>) detailFromJson;

  /// Configuração de backup, contendo as políticas para salvar respostas.
  final BackupConfig backupConfig;

  /// Retorna o campo padrão onde estão os dados a serem mapeados numa listagem.
  ///
  /// Exemplo onde os itens estão na chave `"items"` do json:
  /// ```
  /// rootField: (response) => response.data['items'],
  /// ```
  final dynamic Function(Response) rootField;

  SimpleRepositoryConfig({
    @required String Function() modelUrl,
    @required this.shortFromJson,
    @required this.detailFromJson,
    this.backupConfig,
    this.rootField,
  }) : super(endpointUrl: modelUrl);
}

class AuthConfig<T extends Token> extends RepositoryConfig {
  final T Function(Map<String, dynamic>) fromJson;

  /// Determina se o [Token] é armazenado após o login ser bem-sucedido.
  /// É armazenada na chave `login_token`.
  final bool storeToken;

  /// Endpoint para realizar reauteinticação a partir do [Token], se houver.
  final String reauthEndpoint;

  AuthConfig({
    @required String Function() authEndpoint,
    @required this.fromJson,
    this.storeToken = true,
    this.reauthEndpoint,
  })  : assert(fromJson != null),
        super(endpointUrl: authEndpoint);
}

/// Configuração de Backup.
///
/// Contém as [BackupPolicy] dos métodos, que serão submetidas nas requisições
/// e posteriormente interceptadas pelo [BackupInterceptor].
///
/// Você pode estender esta classe e definir sua própria configuração de backup
/// baseado nos métodos que você tem implementado no seu repositório.
class BackupConfig {
  /// Política para o método `find` do repositório.
  final BackupPolicy find;

  /// Política para o método `findById` do repositório.
  final BackupPolicy findById;

  const BackupConfig({
    this.findById,
    this.find,
  });

  /// Configuração que salva a requisição mais recente do método `find`
  /// e salva todas as requisições do método `findById`.
  static final all = BackupConfig(
    find: SimplePolicy(),
    findById: CounterPolicy.limitless,
  );

  /// Apenas o método `find` terá sua requisição mais recente salva.
  factory BackupConfig.findOnly() => BackupConfig(
        find: SimplePolicy(),
      );

  /// Apenas o método `findById` terá as [count] requisições mais recentes
  /// salvas.
  /// Use `count = -1` para salvar todas as requisições.
  factory BackupConfig.findByIdOnly(int count) => BackupConfig(
        findById: CounterPolicy(count),
      );
}
