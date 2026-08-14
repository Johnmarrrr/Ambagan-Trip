import 'package:drift/drift.dart';
import 'package:ambagan_trip/database/tables/trips.dart';

class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tripId => integer().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get mealType => text()(); // Breakfast, Lunch, Dinner, Snacks
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
