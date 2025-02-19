import 'package:bloc/bloc.dart';
import '../models/error.dart';

/// BLoC genérico da Eureka.
///
/// Todos os BLoCs devem estender direta ou indiretamente desta classe.
abstract class EurekaBloc<E extends EurekaEvent, S extends EurekaState>
    extends Bloc<E, S> {}

/// Evento de BLoC genérico da Eureka.
///
/// Todos os eventos devem estender direta ou indiretamente desta classe.
abstract class EurekaEvent {}

/// Estado de BLoC genérico da Eureka.
//
/// Todos os estados devem estender direta ou indiretamente desta classe.
abstract class EurekaState {}

/// Interface `EurekaState` de falha genérica.
///
/// Todos os estados de falha devem implementar direta ou indiretamente desta classe.
abstract class IEurekaFailState extends EurekaState {
  ErrorModel get error;
}

/// Interface `EurekaState` de sucesso genérico.
abstract class IEurekaSuccessState extends EurekaState {}
