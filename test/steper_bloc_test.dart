import 'dart:io' as io;

import 'package:altair/altair.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'src/person.dart';
import 'src/person_step_bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(transition.toString());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  io.HttpOverrides.global = null;

  PersonStepBloc bloc;
  PersonShort toBeExpected = PersonShort(id: 1, name: 'Taylor Swift');

  setUp(() async {
    BlocSupervisor.delegate = SimpleBlocDelegate();
    bloc = PersonStepBloc();
  });

  tearDown(() {
    bloc?.close();
  });

  test('UpdateModel', () {
    bloc.add(UpdateModelStep(model: toBeExpected));
    bloc.add(ClearStepBloc<PersonShort>());

    expectLater(
      bloc,
      emitsInOrder([
        CurrentStateStep<PersonShort>(model: PersonShort()),
        CurrentStateStep<PersonShort>(model: toBeExpected),
        CurrentStateStep<PersonShort>(model: PersonShort()),
      ]),
    );
  });
}
