// Lembre-se de reiniciar a API de testes a cada vez que rodar o coverage
// pois o objeto esperado não terá mais id 4

import 'dart:convert';
import 'dart:io' as io;

import 'package:altair/altair.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'src/person.dart';
import 'src/person_bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(transition.toString());
  }
}

// Representando apenas id, pois no model definimos que o Equatable
// deve considerar apenas o id para comparar os objetos
String jsonList = ''' [ { "id": 1 }, { "id": 2 }, { "id": 3 } ] ''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  io.HttpOverrides.global = null;

  DistinctPersonBloc bloc;
  List<PersonShort> expectedList;

  setUp(() async {
    BlocSupervisor.delegate = SimpleBlocDelegate();
    bloc = DistinctPersonBloc();

    expectedList = (jsonDecode(jsonList) as List)
        .map((j) => PersonShort.fromJson(j))
        .toList();
  });

  tearDown(() {
    bloc?.close();
  });

  test('LoadEvent', () {
    bloc.add(LoadEvent());
    bloc.add(LoadEvent());
    bloc.add(LoadEvent());
    bloc.add(LoadEvent());

    expectLater(
      bloc,
      emitsInOrder([
        UninitializedState(),
        LoadingState(),
        SuccessState<PersonShort, PersonDetailed>(
          briefs: expectedList,
        ),
      ]),
    );
  });
}
