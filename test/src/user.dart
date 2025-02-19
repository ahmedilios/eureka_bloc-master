import 'package:altair/altair.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable implements Token {
  final int id;
  final String token;

  User({this.id, this.token});

  @override
  Map<String, dynamic> toJson() => {};

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: 1,
        token: json['accessToken'],
      );

  List get props => [id];
}
