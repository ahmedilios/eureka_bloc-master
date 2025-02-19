/// Classe para gerenciar as opções de paginamento, sendo passada no evento de
/// `load`. Principalmente utilizada para saber se uma requisição precisa ser
/// paginada inicialmente e com quantos registros por requisição.
class PageOptions {
  final bool paginated;
  final int limitPerRequest;

  const PageOptions({
    this.paginated = true,
    this.limitPerRequest,
  });
}
