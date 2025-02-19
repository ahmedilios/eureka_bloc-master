/// Esquema de email, usuário e senha padrão para autenticações.
///
/// O repositório de autenticação manipula esse modelo a fim de efetuar a
/// autenticação.
///
/// Você pode estender essa classe a fim de contemplar as particularidades do
/// seu login.
class LoginModel {
  /// Username para login.
  final String identifier;

  /// Senha para login.
  final String password;

  /// Construtor básico para casos genéricos
  LoginModel(
    this.identifier,
    this.password,
  );
}
