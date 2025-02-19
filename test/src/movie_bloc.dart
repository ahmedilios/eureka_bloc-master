import 'package:altair/altair.dart';

import 'movie.dart';
import 'movie_repository.dart';

class MovieBloc
    extends SimpleBloc<MovieModelShort, MovieModelDetail, MovieRepository> {
  @override
  MovieRepository get repository => MovieRepository();

  @override
  Stream<SimpleState> mapEventToState(SimpleEvent event) async* {
    yield* super.mapEventToState(event);
    // implement mapEventToState for other events
  }
}
