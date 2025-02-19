import 'package:equatable/equatable.dart';

import '../../bloc/eureka.dart';
import '../../models/auth/token.dart';
import '../../models/error.dart';

/// Estado base para um BLoC de autenticação.
abstract class AuthState extends EurekaState with EquatableMixin {}

/// Estado de Não-Autenticado do BLoC, implementa a interface [IEurekaFailState]
/// e possui um [ErrorModel] para lidar com os erros de autenticação.
class Unauthenticated extends AuthState implements IEurekaFailState {
  final ErrorModel error;

  Unauthenticated({
    this.error,
  });

  @override
  List get props => [error];
}

/// Estado Autenticado do BLoC, possuindo um model que extende a classe [Token]
/// que armazena os dados do usuário autenticado
class Authenticated extends AuthState {
  Token model;

  Authenticated({
    this.model,
  });

  @override
  List get props => [model];
}

/// Estado de carregamento do BLoC
class AuthLoading extends AuthState {
  @override
  List get props => [];
}
