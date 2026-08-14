import 'package:drift/drift.dart';
import 'package:ambagan_trip/database/tables/trips.dart';

class Participants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tripId => integer().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get contact => text().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get expectedContribution => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
