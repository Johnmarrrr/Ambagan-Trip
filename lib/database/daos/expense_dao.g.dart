// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_dao.dart';

// ignore_for_file: type=lint
mixin _$ExpenseDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripsTable get trips => attachedDatabase.trips;
  $ParticipantsTable get participants => attachedDatabase.participants;
  $ExpensesTable get expenses => attachedDatabase.expenses;
  ExpenseDaoManager get managers => ExpenseDaoManager(this);
}

class ExpenseDaoManager {
  final _$ExpenseDaoMixin _db;
  ExpenseDaoManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db.attachedDatabase, _db.trips);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db.attachedDatabase, _db.participants);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
}
