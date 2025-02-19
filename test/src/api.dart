import 'package:altair/altair.dart';
import 'package:dio/dio.dart';

import 'env.dart';

class Api extends SimpleApi {
  Api._()
      : super(
          Dio(
            BaseOptions(
              baseUrl: Test.baseUrl,
              connectTimeout: Test.connectTimeout,
              receiveTimeout: Test.receiveTimeout,
              followRedirects: true,
            ),
          ),
        );

  static final Api _instance = Api._();

  static Api get instance => _instance;
}
