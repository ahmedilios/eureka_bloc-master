import 'package:equatable/equatable.dart';
import 'package:altair/altair.dart';

class PersonShort extends Equatable implements ShortModel {
  final int id;
  final String name;

  List get props => [id];

  PersonShort({
    this.id,
    this.name,
  });

  factory PersonShort.fromJson(Map<String, dynamic> json) => PersonShort(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class PersonDetailed extends Equatable implements DetailModel {
  final int id;
  final String name;
  final String cpf;
  final String nascimento;

  List get props => [id];

  PersonDetailed({
    this.id,
    this.name,
    this.cpf,
    this.nascimento,
  });

  factory PersonDetailed.fromJson(Map<String, dynamic> json) => PersonDetailed(
        id: json["id"],
        name: json["name"],
        cpf: json["cpf"],
        nascimento: json["nascimento"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "cpf": cpf,
        "nascimento": nascimento,
      };
}
