import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/database_provider.dart';

final participantRepositoryProvider = Provider<ParticipantRepository>((ref) {
  return ParticipantRepository(ref.watch(databaseProvider));
});

class ParticipantRepository {
  final AppDatabase _db;

  ParticipantRepository(this._db);

  Stream<List<Participant>> watchParticipantsForTrip(int tripId) {
    return _db.participantDao.watchParticipantsForTrip(tripId);
  }

  Future<Participant> getParticipant(int id) {
    return _db.participantDao.getParticipant(id);
  }

  Future<int> addParticipant(ParticipantsCompanion participant) {
    return _db.participantDao.insertParticipant(participant);
  }

  Future<bool> updateParticipant(Participant participant) {
    return _db.participantDao.updateParticipant(participant);
  }

  Future<int> deleteParticipant(int id) {
    return _db.participantDao.deleteParticipant(id);
  }
}
