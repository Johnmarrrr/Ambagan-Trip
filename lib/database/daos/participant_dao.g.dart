// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_dao.dart';

// ignore_for_file: type=lint
mixin _$ParticipantDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripsTable get trips => attachedDatabase.trips;
  $ParticipantsTable get participants => attachedDatabase.participants;
  ParticipantDaoManager get managers => ParticipantDaoManager(this);
}

class ParticipantDaoManager {
  final _$ParticipantDaoMixin _db;
  ParticipantDaoManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db.attachedDatabase, _db.trips);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db.attachedDatabase, _db.participants);
}
