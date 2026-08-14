import 'package:drift/drift.dart';
import 'package:ambagan_trip/database/tables/trips.dart';
import 'package:ambagan_trip/database/tables/foods.dart';

class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tripId => integer().references(Trips, #id, onDelete: KeyAction.cascade)();
  IntColumn get foodId => integer().references(Foods, #id, onDelete: KeyAction.cascade).nullable()();
  TextColumn get name => text()();
  TextColumn get quantity => text().nullable()();
  BoolColumn get isBought => boolean().withDefault(const Constant(false))();
  RealColumn get estimatedCost => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
