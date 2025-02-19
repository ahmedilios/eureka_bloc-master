export 'package:dio/dio.dart' show Options, Response, RequestOptions;
import 'package:dio/dio.dart' show Options, Response, RequestOptions;
import '../resources/storage.dart';

/// Política de Backup.
///
/// Uma política de backup é utilizada pelo [BackupInterceptor] para fazer a
/// persistência de dados em caso de sucesso e a recuperação de dados em caso
/// de erro.
///
/// Você deve estender essa classe para criar sua própria política de backup.
///
/// Os métodos [save] e [retrieve] farão, respectivamente, a persistência dos
/// dados no banco e a leitura dos dados no banco. Ao sobrescrever esses métodos
/// você pode embutir suas próprias condições para que essas operações
/// aconteçam. Os registros no banco seguem o padrão chave-valor e, por isso,
/// cada registro deve ser unicamente identificado pela chave [getKey], gerada
/// a partir dos dados da requisição.
abstract class BackupPolicy {
  /// Identificador da política no [Options] da requisição.
  static const String identifier = 'backup-policy';

  BackupPolicy();

  /// Provedor de acesso ao banco.
  final cache = StorageManager.storage;

  /// Retorna a [Options] a ser submetida em uma requisição para que a
  /// política possa ser executada.
  Options get options => Options(extra: {identifier: this});

  /// Salva a [response] com base nas condições da política.
  Future<void> save(Response response);

  /// Retorna, se houver, os dados armazenados com base na [request].
  Future<dynamic> retrieve(RequestOptions request);

  /// Gera uma chave baseada na [request] para acessar o armazenamento.
  String getKey(RequestOptions request);

  @override
  String toString() => identifier;
}
