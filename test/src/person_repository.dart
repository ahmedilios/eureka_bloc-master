import 'package:altair/altair.dart';

import 'api.dart';
import 'person.dart';

class PersonRepository extends SimpleRepository<PersonShort, PersonDetailed> {
  @override
  Api get api => Api.instance;

  @override
  SimpleRepositoryConfig<PersonShort, PersonDetailed> get config =>
      SimpleRepositoryConfig(
        modelUrl: () => '/people',
        shortFromJson: (json) => PersonShort.fromJson(json),
        detailFromJson: (json) => PersonDetailed.fromJson(json),
        backupConfig: BackupConfig.all,
      );
}
