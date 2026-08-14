import 'package:drift/drift.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/tables/participants.dart';

part 'participant_dao.g.dart';

@DriftAccessor(tables: [Participants])
class ParticipantDao extends DatabaseAccessor<AppDatabase> with _$ParticipantDaoMixin {
  ParticipantDao(super.db);

  Stream<List<Participant>> watchParticipantsForTrip(int tripId) {
    return (select(participants)..where((p) => p.tripId.equals(tripId))).watch();
  }

  Future<Participant> getParticipant(int id) {
    return (select(participants)..where((p) => p.id.equals(id))).getSingle();
  }

  Future<int> insertParticipant(ParticipantsCompanion participant) {
    return into(participants).insert(participant);
  }

  Future<bool> updateParticipant(Participant participant) {
    return update(participants).replace(participant);
  }

  Future<int> deleteParticipant(int id) {
    return (delete(participants)..where((p) => p.id.equals(id))).go();
  }
}
