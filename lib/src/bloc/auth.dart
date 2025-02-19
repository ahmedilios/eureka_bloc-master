import 'package:meta/meta.dart';

import '../bloc/eureka.dart';
import '../bloc/events/auth.dart';
import '../bloc/states/auth.dart';
import '../repositories/auth.dart';

export '../bloc/events/auth.dart';
export '../bloc/states/auth.dart';

/// BLoC básico de Autenticação
///
/// Este BLoC fornece a estrutura básica para realizar uma autenticação em um
/// servidor remoto, podendo ser extendido para qualquer tipo de autenticação
/// sobreescrevendo o [AuthRepository].
///
/// O fluxo dentro do [AuthBloc] para um cenário de login se inicia com um
/// evento [AuthLogin] possuindo um [LoginModel] com todas as informações para
/// o login remoto. O login cairá em um estado de [Authenticated] caso tenha
/// sido um sucesso, e em um estado [Unauthenticated] caso contrário.
///
/// Toda lógica de processamento reside no [authRepository] que é o único
/// parâmetro esperado pelo [AuthBloc]
///
/// Um exemplo de [AuthRepository] para um login de JWT se dá da forma:
///
/// ````
/// class AuthJwt extends AuthRepository {
///   @override
///   Api get api => Api.instance;
///
///   @override
///   Map<String, String> dataToAuth(LoginModel model) => {
///         'email': model.email,
///         'password': model.password,
///       };
///
///   @override
///   void callbackLogin(Token authModel) {}
///
///   static Token fromJson(Map<String, dynamic> map) {
///     return null;
///   }
///
///   AuthJwt()
///       : super(
///           config: AuthConfig(
///             authEndpoint: '/usuarios/login',
///             fromJson: fromJson,
///           ),
///         );
/// }
/// ```
///
/// Com um repository implementado, para instanciar um [AuthBloc] só é preciso:
/// ```
/// authBloc = AuthBloc(AuthJwt());
/// ```
///
class AuthBloc extends EurekaBloc<AuthEvent, AuthState> {
  AuthRepository authRepository;

  AuthBloc({
    @required this.authRepository,
  }) : assert(authRepository != null);

  @override
  AuthState get initialState => Unauthenticated();

  @override
  @mustCallSuper
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AuthRestore) yield* _authRestore(event);
    if (event is AuthLogin) yield* _authLogin(event);
    if (event is AuthLogout) yield* _authLogout(event);
    if (event is AuthForced) yield* _authForced(event);
  }

  Stream<AuthState> _authForced(AuthForced event) async* {
    if (event.token != null) {
      await this.authRepository.authHandler(event.token);
      yield Authenticated(
        model: event.token,
      );
    }
  }

  Stream<AuthState> _authRestore(AuthRestore event) async* {
    yield AuthLoading();
    final response = await this.authRepository.reauth();
    if (response.isSuccessful) {
      yield Authenticated(
        model: response.data,
      );
    } else {
      yield Unauthenticated(
        error: response.error,
      );
    }
  }

  Stream<AuthState> _authLogin(AuthLogin event) async* {
    yield AuthLoading();
    final response = await this.authRepository.login(event.model);
    if (response.isSuccessful) {
      yield Authenticated(
        model: response.data,
      );
    } else {
      yield Unauthenticated(
        error: response.error,
      );
    }
  }

  Stream<AuthState> _authLogout(AuthLogout event) async* {
    await this.authRepository.logout(event.token);
    yield Unauthenticated();
  }
}
