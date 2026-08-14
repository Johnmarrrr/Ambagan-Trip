import 'package:drift/drift.dart';
import 'package:ambagan_trip/database/tables/trips.dart';
import 'package:ambagan_trip/database/tables/participants.dart';

class Pahabilins extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tripId => integer().references(Trips, #id, onDelete: KeyAction.cascade)();
  IntColumn get participantId => integer().references(Participants, #id, onDelete: KeyAction.cascade)();
  TextColumn get itemName => text()();
  RealColumn get estimatedCost => real().withDefault(const Constant(0.0))();
  BoolColumn get isBought => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
