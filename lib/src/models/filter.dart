import 'package:equatable/equatable.dart';

/// Descreve um filtro a ser incluído na requisição à API.
///
/// Você deve estender essa classe e gerar filtros conforme os métodos do seu
/// repositório precisem.
abstract class Filter extends Equatable {
  /// Gera uma [String] a ser concatenada na requisição.
  String get encoded;

  @override
  List get props => [encoded];

  @override
  String toString() => encoded;
}
