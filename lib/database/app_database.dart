import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:ambagan_trip/database/tables/trips.dart';
import 'package:ambagan_trip/database/daos/trip_dao.dart';
import 'package:ambagan_trip/database/tables/participants.dart';
import 'package:ambagan_trip/database/daos/participant_dao.dart';
import 'package:ambagan_trip/database/tables/expenses.dart';
import 'package:ambagan_trip/database/daos/expense_dao.dart';
import 'package:ambagan_trip/database/tables/foods.dart';
import 'package:ambagan_trip/database/daos/food_dao.dart';
import 'package:ambagan_trip/database/tables/ingredients.dart';
import 'package:ambagan_trip/database/daos/ingredient_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Trips, Participants, Expenses, Foods, Ingredients],
  daos: [TripDao, ParticipantDao, ExpenseDao, FoodDao, IngredientDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

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
        if (from < 3) {
          await m.createTable(expenses);
        }
        if (from < 4) {
          await m.createTable(foods);
          await m.createTable(ingredients);
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
