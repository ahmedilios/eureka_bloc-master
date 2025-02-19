import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Descreve um erro ocorrido no BLoC ou Repository.
class ErrorModel extends Equatable {
  /// Descreve textualmente o erro.
  final String message;

  /// Indica se o erro ocorreu por uma não-autorização da API.
  final bool isUnauthorized;

  ErrorModel({
    @required this.message,
    this.isUnauthorized = false,
  });

  List get props => [message, isUnauthorized];

  /// Construtor que gera um erro de não-autorização com uma [message].
  factory ErrorModel.unauthorized(String message) => ErrorModel(
        message: message,
        isUnauthorized: true,
      );
}
