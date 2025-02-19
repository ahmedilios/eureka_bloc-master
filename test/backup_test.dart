import 'dart:io';

import 'package:altair/altair.dart';
import 'package:dio/dio.dart';

import 'package:flutter_test/flutter_test.dart';

class CustomObject {
  int a;
  CustomObject(this.a);

  @override
  String toString() => 'olar';
}

class BackupInterceptor extends Interceptor {
  @override
  Future onResponse(Response response) async {
    // print(response.request.uri.pathSegments);
    // print(response.request.method);
    // print('hereeee');
    final policy =
        response.request.extra[BackupPolicy.identifier] as BackupPolicy;
    print("KEY: ${policy.getKey(response.request)}");
    print("data: ${response.data}");
    // await policy.save(response);
    // final data = await policy.retrieve(response);
    // print("data retrieved: $data");
    // print(response.request.extra);
    return response;
  }

  @override
  Future onError(DioError e) async {
    if (e.type == DioErrorType.DEFAULT) {
      print(e.error is SocketException);
    }
    // print(e.request.extra[BackupPolicy.identifier]);
    // print(e.request.uri.path);
    return e;
  }
}

Future<void> testDio() async {
  Dio dio = Dio()..interceptors.add(BackupInterceptor());
  dio.options.baseUrl = 'http://localhost:3123';
  // final SimplePolicy obj = SimplePolicy();
  final CounterPolicy obj = CounterPolicy(2);

  await dio.get('/people/2', options: obj.options);
}

main() {
  test('Send Request', () async {
    // final response = await repository.find();

    await testDio();
    // expect(response.isSucessfull, true);
  });
}
