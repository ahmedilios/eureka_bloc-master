import 'package:flutter/widgets.dart';

import '../bloc/eureka.dart';
import '../bloc/events/stepper.dart';
import '../bloc/states/stepper.dart';

export '../bloc/events/stepper.dart';
export '../bloc/states/stepper.dart';

/// BLoC básico de Stepper
///
/// Este BLoC fornece a estrutura básica para persistir um modelo [M] entre
/// diferentes screens, sendo utilizado principalmente em formulários.
///
/// O fluxo de atualização do bloc é feito com o evento [UpdateModelStep<M>]
/// para sobreescrever o modelo atualmente no BLoC, e com o evento
/// [ClearStepBloc<M>] para retornar o modelo atual ao modelo definido no
/// [initialState] do BLoC.
///
/// Para instanciar um novo [SteperBloc<M>] passando um modelo no tipo [M]
/// e sobreescrever o método [initialState] com um modelo inicial, sendo esse
/// normalmente um modelo vazio.
///
/// Exemplo simples de utilização:
/// ```
/// class PersonStepBloc extends SteperBloc<PersonShort> {
///   @override
///   StepperState get initialState =>
///       CurrentStateStep<PersonShort>(model: PersonShort());
/// }
/// ```
///
/// Caso seja necessário adicionar novos eventos ao BLoC basta sobreescrever o
/// método [mapEventToState].
///
/// /// Exemplo de utilização com eventos adicionais:
/// ```
/// class PersonStepBloc extends SteperBloc<PersonShort> {
///   @override
///   StepperState get initialState =>
///       CurrentStateStep<PersonShort>(model: PersonShort());
///
///  @override
///  Stream<StepperState> mapEventToState(StepperEvent event) async* {
///    yield* super.mapEventToState(event);
///    // Implement mapEventToState for other events
///  }
/// }
/// ```

abstract class SteperBloc<M> extends EurekaBloc<StepperEvent, StepperState> {
  @override
  StepperState get initialState => null;

  @override
  @mustCallSuper
  Stream<StepperState> mapEventToState(StepperEvent event) async* {
    if (event is UpdateModelStep<M>) yield* _updateModel(event);
    if (event is ClearStepBloc<M>) yield* _clearStepper(event);
  }

  Stream<StepperState> _updateModel(UpdateModelStep event) async* {
    yield CurrentStateStep<M>(model: event.model);
  }

  Stream<StepperState> _clearStepper(event) async* {
    yield initialState;
  }
}
