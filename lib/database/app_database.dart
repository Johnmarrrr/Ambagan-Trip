import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:ambagan_trip/database/tables/trips.dart';
import 'package:ambagan_trip/database/daos/trip_dao.dart';
import 'package:ambagan_trip/database/tables/participants.dart';
import 'package:ambagan_trip/database/daos/participant_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Trips, Participants],
  daos: [TripDao, ParticipantDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(participants);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ambagan_trip.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
