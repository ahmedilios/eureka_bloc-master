import 'package:altair/altair.dart';

import 'api.dart';
import 'user.dart';

class AuthAccessToken extends AuthRepository<User, LoginModel> {
  @override
  Api get api => Api.instance;

  @override
  Map<String, String> dataToAuth(LoginModel model) => {
        'email': model.identifier,
        'password': model.password,
        'strategy': 'local'
      };

  @override
  void callbackLogin(User authModel) {
    api.addHeader(
      header: 'Authorization',
      value: 'Bearer ${authModel.token}',
    );
  }

  @override
  AuthConfig<User> get config => AuthConfig(
        authEndpoint: () => '/authentication',
        fromJson: (json) => User.fromJson(json),
      );
}
