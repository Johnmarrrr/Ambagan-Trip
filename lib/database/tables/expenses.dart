import 'package:drift/drift.dart';
import 'package:ambagan_trip/database/tables/trips.dart';
import 'package:ambagan_trip/database/tables/participants.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tripId => integer().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get category => text()(); // Transport, Accommodation, Food, Activities, Others
  TextColumn get description => text()();
  RealColumn get amount => real()();
  IntColumn get paidById => integer().references(Participants, #id, onDelete: KeyAction.setNull).nullable()();
  DateTimeColumn get expenseDate => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
