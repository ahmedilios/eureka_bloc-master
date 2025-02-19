import 'package:equatable/equatable.dart';
import '../../bloc/eureka.dart';

abstract class StepperEvent extends EurekaEvent with EquatableMixin {}

class UpdateModelStep<M> extends StepperEvent {
  M model;

  UpdateModelStep({
    this.model,
  });

  @override
  List get props => [model];
}

class ClearStepBloc<M> extends StepperEvent {
  @override
  List get props => [];
}
