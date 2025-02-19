import '../policy.dart';

/// Política de backup para uma única resposta de requisição
///
/// Salva uma resposta de requisição com base no [response.request.uri.path] e
/// [response.request.method].
///
/// Um exemplo de estrutura de armazenamento dessa política específica
/// após um `GET` em `/people` seria:
/// ```
/// {
///   "SimplePolicy [GET] /people": [
///     "1": {"name": "Jon"},
///     "2": {"name": "Mary"},
///     "3": {"name": "Eduardo"},
///     "4": {"name": "Patrício"}
///   ]
/// }
/// ```
/// Essa política pode ser usada em métodos `find`, onde a lista de registros
/// mais recente permanece salva.
///
class SimplePolicy extends BackupPolicy {
  @override
  String getKey(RequestOptions request) =>
      "SimplePolicy [${request.method}] ${request.uri.path}";

  @override
  Future<void> save(Response response) async => response.data is List
      ? await this.cache.setList(
            key: this.getKey(response.request),
            list: (response.data as List)
                .map((element) => element as Map<String, dynamic>)
                .toList(),
          )
      : this.cache.set(
            key: this.getKey(response.request),
            value: response.data,
          );

  @override
  Future<dynamic> retrieve(RequestOptions request) async {
    final key = this.getKey(request);
    try {
      return this.cache.get(key: key);
    } catch (e) {
      return this.cache.getList(key: key);
    }
  }
}
