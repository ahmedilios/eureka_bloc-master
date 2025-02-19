import 'package:dio/dio.dart';

import '../../altair.dart';
import '../models/auth/login.dart';
import '../models/auth/token.dart';
import '../models/response.dart';
import '../repositories/config.dart';
import '../repositories/policy.dart';
import '../resources/api.dart';
import '../resources/storage.dart';

/// Repositório base para autenticação, sendo utilizado junto de um AuthBloc.
///
/// Necessita de um [AuthConfig] com o endpoint para autenticação, bem como uma
/// função `fromJson` para mapear o JSON de resposta da autenticação para um
/// modelo que extenda a classe [Token].
///
/// Exemplo de uma implementação de um AuthRepository para uma auteticação JWT:
/// ```
/// class AuthJwt extends AuthRepository {
///  @override
///  Api get api => Api.instance;
///
///  @override
///  Map<String, String> dataToAuth(LoginModel model) => {
///        'email': model.email,
///        'password': model.password,
///      };
///
///  @override
///  void callbackLogin(Token authModel) {}
///
///  static Token fromJson(Map<String, dynamic> map) {
///    return null;
///  }
///
///  AuthJwt()
///      : super(
///          config: AuthConfig(
///            authEndpoint: '/usuarios/login',
///            fromJson: fromJson,
///          ),
///        );
///  }
/// ```
abstract class AuthRepository<AuthModel extends Token,
    Login extends LoginModel> {
  /// Configuração do repositório de autenticação.
  AuthConfig<AuthModel> get config;

  /// Realiza operações após efetuado uma autenticação de sucesso. Normalmente
  /// é utilizado para setar atributos na [api].
  callbackLogin(AuthModel authModel);

  /// Realiza a conversão de um modelo [model] para um JSON no formato esperado
  /// pela API de autenticação.
  Map<String, dynamic> dataToAuth(Login model);

  /// Instância de [EurekaApi] que será utilizada para fazer a requisição de
  /// autenticação. Isso permite a aplicação fazer login em diferentes APIs,
  /// não necessariamente na API utilizada pelo restante do projeto.
  EurekaApi get api;

  /// Recupera o json do modelo de autenticação do armazenamento, caso existir.
  Future<RepositoryResponse> _retrieveFromStorage() async {
    final storedJson = await StorageManager.storage.get(key: 'login_token');
    if (storedJson?.isEmpty ?? true) {
      return RepositoryResponse.failure(
        message: 'Nenhum usuário armazenado',
      );
    }
    return RepositoryResponse.successOnline(
      data: storedJson,
    );
  }

  Future<RepositoryResponse<AuthModel>> authHandler(AuthModel model) async {
    api.authData = model;

    await this.callbackLogin?.call(model);

    if (config.storeToken) {
      await StorageManager.storage.set(
        key: 'login_token',
        value: model?.toJson(),
      );
    }

    return RepositoryResponse.successOnline(data: model);
  }

  /// Trata uma resposta de requisição de autenticação, chamando os devidos
  /// callbacks e, caso configurado, salvando a resposta da requisição.
  // Future<RepositoryResponse<AuthModel>> _authCallBack(Response response) async {
  // final modelResponse = this.config.fromJson(response.data);
  // return authCallBack(modelResponse);
  // }

  /// Realiza a autenticação na [api] com os dados do [model] no endpoint
  /// configurado em [config]. Retorna um objeto do tipo [Token] que é
  /// armazenado caso a propriedade `storeToken` esteja habilitada na [config].
  /// Caso haja necessidade, você opde reescrever esse método.
  Future<RepositoryResponse<AuthModel>> login(Login model) async {
    if (model == null) return reauth();

    try {
      final Response response = await api.post(
        this.config.endpointUrl(),
        data: dataToAuth(model),
      );

      return authHandler(
        this.config.fromJson(response.data),
      );
    } on DioError catch (error) {
      return RepositoryResponse.failure(
        message: api.handleError(error),
        statusCode: error?.response?.statusCode,
      );
    }
  }

  /// Callback invocado quando ocorre um evento de desautenticação.
  /// Realiza um `POST` na `reauthEndpoint` da [config] com o json salvo no
  /// armazenamento, se existir. Retorna um novo [AuthModel], se houver
  /// sucesso, e invoca o `[callbackLogin]`.
  Future<RepositoryResponse<AuthModel>> reauth() async {
    final storedResponse = await _retrieveFromStorage();
    try {
      if (!storedResponse.isSuccessful) throw DioError();

      if (this.config.reauthEndpoint == null) {
        return authHandler(this.config.fromJson(storedResponse.data));
      }

      await this.callbackLogin?.call(this.config.fromJson(storedResponse.data));

      await api.get(
        this.config.reauthEndpoint,
      );

      return authHandler(this.config.fromJson(storedResponse.data));
    } on DioError catch (error) {
      return RepositoryResponse.failure(
        message: api.handleError(error),
        statusCode: error?.response?.statusCode,
      );
    } catch (e) {
      return RepositoryResponse.failure(message: e.toString());
    }
  }

  /// Callback invocado quando ocorre um evento de desautenticação.
  Future<void> logout(AuthModel token) async {
    await StorageManager.storage.delete(key: 'login_token');
  }
}
