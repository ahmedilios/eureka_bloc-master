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
String jsonDetail = ''' { "name": "Euriko", "cpf": "1234567" } ''';
String jsonDetailAfterCreate =
    ''' { "id": 4, "name": "Euriko", "cpf": "1234567" } ''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  io.HttpOverrides.global = null;

  PersonBloc bloc;
  List<PersonShort> expectedList;
  PersonDetailed toCreate;
  PersonDetailed toBeExpected;

  setUp(() async {
    BlocSupervisor.delegate = SimpleBlocDelegate();
    bloc = PersonBloc();

    expectedList = (jsonDecode(jsonList) as List)
        .map((j) => PersonShort.fromJson(j))
        .toList();

    toCreate = PersonDetailed.fromJson(jsonDecode(jsonDetail));
    toBeExpected = PersonDetailed.fromJson(jsonDecode(jsonDetailAfterCreate));
  });

  tearDown(() {
    bloc?.close();
  });

  test('LoadEvent', () {
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

  test('SelectByModel', () {
    bloc.add(SelectEvent.byModel(expectedList[0]));

    expectLater(
      bloc,
      emitsInOrder([
        UninitializedState(),
        LoadingState(),
        SuccessState<PersonShort, PersonDetailed>(
          focused: PersonDetailed.fromJson(expectedList[0].toJson()),
        ),
      ]),
    );
  });

  test('SelectById', () {
    bloc.add(SelectEvent.byId(expectedList[0].id));

    expectLater(
      bloc,
      emitsInOrder([
        UninitializedState(),
        LoadingState(),
        SuccessState<PersonShort, PersonDetailed>(
          focused: PersonDetailed.fromJson(expectedList[0].toJson()),
        ),
      ]),
    );
  });

  test('SelectByCacheKey', () {
    bloc.add(SelectEvent.byCacheKey(expectedList[0].id.toString()));

    expectLater(
      bloc,
      emitsInOrder([
        UninitializedState(),
        LoadingState(),
        SuccessState<PersonShort, PersonDetailed>(
          focused: PersonDetailed.fromJson(expectedList[0].toJson()),
        ),
      ]),
    );
  });

  test('CreateEvent', () {
    bloc.add(CreateEvent(detailed: toCreate));

    expectLater(
      bloc,
      emitsInOrder([
        UninitializedState(),
        LoadingState(),
        SuccessState<PersonShort, PersonDetailed>(
          focused: toBeExpected,
        ),
      ]),
    );
  });

  test('UpdateEvent', () {
    bloc.add(UpdateEvent(detailed: toBeExpected));

    expectLater(
      bloc,
      emitsInOrder([
        UninitializedState(),
        LoadingState(),
        SuccessState<PersonShort, PersonDetailed>(
          focused: toBeExpected,
        ),
      ]),
    );
  });

  test('DeleteEvent', () {
    bloc.add(DeleteEvent.byModel(toBeExpected));

    expectLater(
      bloc,
      emitsInOrder([
        UninitializedState(),
        LoadingState(),
        SuccessState<PersonShort, PersonDetailed>(
          focused: toBeExpected,
        ),
      ]),
    );
  });
}
