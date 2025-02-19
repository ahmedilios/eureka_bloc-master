import 'package:altair/altair.dart';

import 'api.dart';
import 'movie.dart';

class MovieRepository
    extends SimpleRepository<MovieModelShort, MovieModelDetail> {
  @override
  Api get api => Api.instance;

  @override
  SimpleRepositoryConfig<MovieModelShort, MovieModelDetail> get config =>
      SimpleRepositoryConfig(
        rootField: (response) => response.data['data'],
        modelUrl: () => '/movies',
        shortFromJson: (json) => MovieModelShort.fromJson(json),
        detailFromJson: (json) => MovieModelDetail.fromJson(json),
        backupConfig: null,
      );
}
