import 'package:altair/altair.dart';
import 'package:equatable/equatable.dart';

class MovieModelShort extends Equatable implements ShortModel {
  final String id;
  final String name;
  final String duration;

  List get props => [id];

  MovieModelShort({
    this.id,
    this.name,
    this.duration,
  });

  factory MovieModelShort.fromJson(Map<String, dynamic> json) =>
      MovieModelShort(
        id: json['_id'],
        name: json['name'],
        duration: json['duration'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'duration': duration,
      };
}

class MovieModelDetail extends Equatable implements DetailModel {
  final String id;
  final String name;
  final String duration;

  List get props => [id];

  MovieModelDetail({
    this.id,
    this.name,
    this.duration,
  });

  factory MovieModelDetail.fromJson(Map<String, dynamic> json) =>
      MovieModelDetail(
        id: json['_id'],
        name: json['name'],
        duration: json['duration'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'duration': duration,
      };
}

const String movieList = '''
    [{
      "_id": "5ed1592987ca193550f487e3",
      "name": "Blade Runner 2049",
      "duration": "02:00"
    },
    {
      "_id": "5ed15d84d2e10d30b88c3322",
      "name": "Blade Runner 2049",
      "duration": "02:00"
    },
    {
      "_id": "5ed175b9d37ef337c041eac3",
      "name": "Blade Runner 2049",
      "duration": "02:00"
    },
    {
      "_id": "5ed4feb05f27a116b806863e",
      "name": "Blade Runner Teste",
      "duration": "03:00"
    },
    {
      "_id": "5ed517d0c9d3d92c74c9119d",
      "name": "Blade Runner Teste",
      "duration": "03:00"
    }]
 ''';
