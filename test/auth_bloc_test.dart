import 'dart:io' as io;

import 'package:altair/altair.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'src/auth_repository.dart';
import 'src/user.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('${bloc.toString()} ${transition.toString()}');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  io.HttpOverrides.global = null;
  AuthBloc bloc;

  setUp(() async {
    BlocSupervisor.delegate = SimpleBlocDelegate();
    bloc = AuthBloc(authRepository: AuthAccessToken());
  });

  tearDown(() {
    bloc?.close();
  });

  test('Login', () {
    bloc.add(
      AuthLogin(
        model: LoginModel('gui', 'gui'),
      ),
    );

    expectLater(
      bloc,
      emitsInOrder(
        [
          Unauthenticated(),
          AuthLoading(),
          Authenticated(
            model: User(id: 1),
          ),
        ],
      ),
    );
  });
}
