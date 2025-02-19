import 'package:equatable/equatable.dart';

import '../../bloc/eureka.dart';

abstract class StepperState extends EurekaState with EquatableMixin {}

class CurrentStateStep<M> extends StepperState {
  M model;

  CurrentStateStep({
    this.model,
  });

  @override
  List get props => [model];
}
