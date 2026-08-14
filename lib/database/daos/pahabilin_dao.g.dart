// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pahabilin_dao.dart';

// ignore_for_file: type=lint
mixin _$PahabilinDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripsTable get trips => attachedDatabase.trips;
  $ParticipantsTable get participants => attachedDatabase.participants;
  $PahabilinsTable get pahabilins => attachedDatabase.pahabilins;
  PahabilinDaoManager get managers => PahabilinDaoManager(this);
}

class PahabilinDaoManager {
  final _$PahabilinDaoMixin _db;
  PahabilinDaoManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db.attachedDatabase, _db.trips);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db.attachedDatabase, _db.participants);
  $$PahabilinsTableTableManager get pahabilins =>
      $$PahabilinsTableTableManager(_db.attachedDatabase, _db.pahabilins);
}
