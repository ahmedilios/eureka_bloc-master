import 'package:equatable/equatable.dart';
import '../../bloc/eureka.dart';
import '../../models/auth/login.dart';
import '../../models/auth/token.dart';

abstract class AuthEvent extends EurekaEvent with EquatableMixin {}

class AuthRestore extends AuthEvent {
  @override
  List get props => [];
}

class AuthLogin extends AuthEvent {
  final LoginModel model;

  AuthLogin({
    this.model,
  });

  @override
  List get props => [model];
}

class AuthLogout extends AuthEvent {
  final Token token;

  AuthLogout({
    this.token,
  });

  @override
  List get props => [token];
}

class AuthForced extends AuthEvent {
  final Token token;

  AuthForced({
    this.token,
  });

  @override
  List get props => [token];
}
