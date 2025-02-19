import 'package:eureka_cache/eureka_cache.dart';

/// Gerencia a instância de acesso ao armazenamento da aplicação.
///
/// Garante que todas as transações sejam executadas sob a mesma instância de
/// armazenamento [storage] e, portanto, com a mesma trava (lock).
class StorageManager {
  /// Instância única de armazenamento.
  static final storage = Cache();
}
