import 'dart:convert';
import 'dart:io' as io;

import 'package:altair/altair.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'src/api.dart';
import 'src/movie.dart';
import 'src/movie_bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (transition.nextState is SuccessState) {
      final state = (transition.nextState as SuccessState);
      print(
          'briefs length: ${state.briefs.length}, filters: ${state.filters}, hasReachedMax: ${state.hasReachedMax}');
    }
    debugPrint(transition.toString());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  io.HttpOverrides.global = null;

  MovieBloc bloc;

  List<MovieModelShort> expectedList;

  setUp(
    () async {
      BlocSupervisor.delegate = SimpleBlocDelegate();
      bloc = MovieBloc();

      expectedList = (jsonDecode(movieList) as List)
          .map((j) => MovieModelShort.fromJson(j))
          .toList();

      Api.instance.addHeader(
          header: 'Authorization',
          value:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6ImFjY2VzcyJ9.eyJpYXQiOjE1OTE2MjM5NzIsImV4cCI6MTU5MTcxMDM3MiwiYXVkIjoiaHR0cHM6Ly95b3VyZG9tYWluLmNvbSIsImlzcyI6ImZlYXRoZXJzIiwic3ViIjoiNWVkMTQ1NDNhZGY4ODAzYTQ0MjQ2NWMzIiwianRpIjoiMzM1MmE2N2MtYmIzOS00MmY4LTk1MGMtYjRmNzE4MDc0MjAwIn0.K-62PkiM9zzjCIQ7qQfDyaY7oZ2l4mCJf0Wa28D_mkk');
    },
  );

  tearDown(() {
    bloc?.close();
  });

  test('Load Without Pagination', () {
    bloc.add(LoadEvent());

    expectLater(
      bloc,
      emitsInOrder(
        [
          UninitializedState(),
          LoadingState(),
          SuccessState<MovieModelShort, MovieModelDetail>(
            briefs: expectedList,
            filters: {},
            hasReachedMax: false,
          ),
        ],
      ),
    );
  });

  test(
    'Load Paginated',
    () {
      bloc.add(
        LoadEvent(
          pageOptions: PageOptions(limitPerRequest: 1),
        ),
      );

      bloc.add(NextEvent());
      bloc.add(NextEvent());
      bloc.add(NextEvent());
      bloc.add(NextEvent());
      bloc.add(NextEvent());

      expectLater(
        bloc,
        emitsInOrder(
          [
            UninitializedState(),
            LoadingState(),
            SuccessState<MovieModelShort, MovieModelDetail>(
              briefs: expectedList.sublist(0, 1),
              filters: <Filter>{
                FilterPagination(
                  offset: 0,
                  limit: 1,
                ),
              },
              hasReachedMax: false,
            ),
            LoadingState(),
            SuccessState<MovieModelShort, MovieModelDetail>(
              briefs: expectedList.sublist(0, 2),
              filters: <Filter>{
                FilterPagination(
                  offset: 1,
                  limit: 1,
                ),
              },
              hasReachedMax: false,
            ),
            LoadingState(),
            SuccessState<MovieModelShort, MovieModelDetail>(
              briefs: expectedList.sublist(0, 3),
              filters: <Filter>{
                FilterPagination(
                  offset: 2,
                  limit: 1,
                ),
              },
              hasReachedMax: false,
            ),
            LoadingState(),
            SuccessState<MovieModelShort, MovieModelDetail>(
              briefs: expectedList.sublist(0, 4),
              filters: <Filter>{
                FilterPagination(
                  offset: 3,
                  limit: 1,
                ),
              },
              hasReachedMax: false,
            ),
            LoadingState(),
            SuccessState<MovieModelShort, MovieModelDetail>(
              briefs: expectedList.sublist(0, 5),
              filters: <Filter>{
                FilterPagination(
                  offset: 4,
                  limit: 1,
                ),
              },
              hasReachedMax: false,
            ),
            LoadingState(),
            SuccessState<MovieModelShort, MovieModelDetail>(
              briefs: expectedList.sublist(0, 5),
              filters: <Filter>{
                FilterPagination(
                  offset: 5,
                  limit: 1,
                ),
              },
              hasReachedMax: true,
            ),
          ],
        ),
      );
    },
  );
}
