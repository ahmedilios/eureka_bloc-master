import 'package:bloc/bloc.dart';

import '../bloc/eureka.dart';

/// Mixin para processar apenas eventos distintos.
///
/// Deve-se implementar esse Mixin no BLoC cuja intenção seja que apenas eventos
/// sequenciais distintos sejam considerados para o `mapEventToState`. Logo, se
/// dois eventos iguais forem emitidos em sequência, apenas um será processado.
///
/// O critério para diferenciar eventos é definido pelo [Equatable].
///
/// O BLoC em questão deve utilizar eventos [EurekaEvent] e estados
/// [EurekaState].
///
/// Exemplo de utilização:
/// ```
/// class DistinctPersonBloc extends SimpleBloc with DistinctEventMixin {}
/// ```
/// O efeito prático gerado é que se dois eventos `EventLoad`, por exemplo,
/// forem disparados em sequência, apenas um será considerado para
/// processamento no método `mapEventToState` do BLoC.
///
/// **ATENÇÃO**: O uso deste Mixin pode trazer efeitos indesejados, uma vez que
/// todos os eventos do BLoC estarão suscetíveis à não-sequencialidade.
mixin DistinctEventMixin<E extends EurekaEvent, S extends EurekaState>
    on Bloc<E, S> {
  @override
  Stream<Transition<E, S>> transformEvents(events, next) {
    return super.transformEvents(
      events.distinct(),
      next,
    );
  }
}
