import 'package:altair/altair.dart';

import 'person.dart';
import 'person_repository.dart';

class PersonBloc
    extends SimpleBloc<PersonShort, PersonDetailed, PersonRepository> {
  @override
  PersonRepository get repository => PersonRepository();

  @override
  Stream<SimpleState> mapEventToState(SimpleEvent event) async* {
    yield* super.mapEventToState(event);
    // implement mapEventToState for other events
  }
}

class DistinctPersonBloc
    extends SimpleBloc<PersonShort, PersonDetailed, PersonRepository>
    with DistinctEventMixin {
  @override
  PersonRepository get repository => PersonRepository();

  @override
  Stream<SimpleState> mapEventToState(SimpleEvent event) async* {
    yield* super.mapEventToState(event);
    // implement mapEventToState for other events
  }
}
