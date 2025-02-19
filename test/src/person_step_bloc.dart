import 'package:altair/altair.dart';

import 'person.dart';

class PersonStepBloc extends SteperBloc<PersonShort> {
  @override
  StepperState get initialState =>
      CurrentStateStep<PersonShort>(model: PersonShort());
}
