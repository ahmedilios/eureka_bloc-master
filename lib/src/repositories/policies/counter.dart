import '../policy.dart';

/// Política de backup que salva múltiplas respostas de uma mesma requisição.
///
/// Ao salvar uma resposta de requisição, garante que existam no máximo
/// [saveCount] respostas com os mesmos sub-componentes de `pathSegments` para
/// um mesmo `method`.
///
/// Faz uso do `method` e dos `n-1` elementos do `pathSegments` para gerar a
/// chave de armazenamento para um registro interno onde constam, no máximo,
/// [saveCount] outras entradas, cada qual com a chave sendo o `n-ésimo`
/// elemento do `pathSegments`.
///
/// Dada a requisição `GET` em `/people/1`, tem-se `pathSegments = [people, 1]`
/// e `method = GET`. Assim, a chave seria formada pelo sub-componente `people`
/// e pelo método `GET`. Isso implica que o último componente do caminho da
/// requisição é **ignorado** para chave do registro, sendo usado para indexar
/// uma requisição específica deste mesmo endpoint.
///
/// Um exemplo de estrutura de armazenamento dessa política específica
/// após um `GET` em `/people/1` e em `/people/2` seria:
/// ```
/// {
///   "CounterPolicy [GET] /people":{
///     "1": {"name": "Jon"},
///     "2": {"name": "Mary"}
///   }
/// }
/// ```
/// Caso o exemplo acima tenha um `saveCount = 2`, então uma requisição
/// `GET` em `/people/3` resultaria na estrutura de armazenamento:
/// ```
/// {
///   "CounterPolicy [GET] /people":{
///     "2": {"name": "Mary"},
///     "3": {"name": "Eduardo"}
///   }
/// }
/// ```
/// Essa política pode ser usada em métodos `findById`, onde os últimos
/// [saveCount] registros buscados permanecem salvos.
///
class CounterPolicy extends BackupPolicy {
  /// Quantidade máxima de respostas a serem salvas.
  final int saveCount;

  CounterPolicy(this.saveCount);

  /// Salva qualquer quantidade de respostas.
  static final limitless = CounterPolicy(-1);

  String internalKey(RequestOptions request) =>
      request.uri.pathSegments.isEmpty ? '/' : request.uri.pathSegments.last;

  @override
  String getKey(RequestOptions request) {
    final base = "CounterPolicy [${request.method}]";
    final Iterable<String> pathList = request.uri.pathSegments.isEmpty
        ? []
        : request.uri.pathSegments.take(request.uri.pathSegments.length - 1);
    final pathString = pathList.join('/');
    return "$base /$pathString";
  }

  @override
  Future<void> save(Response response) async {
    if (this.saveCount == 0) return;

    final key = this.getKey(response.request);
    final Map<String, dynamic> record = await this.cache.get(key: key) ?? {};

    final internalKey = this.internalKey(response.request);

    if (record.keys.length == this.saveCount &&
        !record.keys.contains(internalKey)) {
      record.remove(record.keys.first);
    }
    record.update(
      internalKey,
      (_) => response.data,
      ifAbsent: () => response.data,
    );

    await this.cache.set(
          key: key,
          value: record,
        );
  }

  @override
  Future<dynamic> retrieve(RequestOptions request) async {
    final key = this.getKey(request);
    final record = await this.cache.get(key: key);

    if (record == null || record.isEmpty) return null;

    final internalKey = this.internalKey(request);

    return record[internalKey];
  }
}
