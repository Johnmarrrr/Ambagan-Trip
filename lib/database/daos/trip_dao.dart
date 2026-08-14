import 'package:drift/drift.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/tables/trips.dart';

part 'trip_dao.g.dart';

@DriftAccessor(tables: [Trips])
class TripDao extends DatabaseAccessor<AppDatabase> with _$TripDaoMixin {
  TripDao(AppDatabase db) : super(db);

  Stream<List<Trip>> watchAllTrips() => (select(trips)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  
  Stream<List<Trip>> watchActiveTrips() {
    return (select(trips)
      ..where((t) => t.status.isIn(['upcoming', 'active']))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
    ).watch();
  }

  Stream<List<Trip>> watchCompletedTrips() {
    return (select(trips)
      ..where((t) => t.status.equals('completed'))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
    ).watch();
  }

  Future<Trip> getTrip(int id) => (select(trips)..where((t) => t.id.equals(id))).getSingle();
  Stream<Trip> watchTrip(int id) => (select(trips)..where((t) => t.id.equals(id))).watchSingle();

  Future<int> insertTrip(TripsCompanion trip) => into(trips).insert(trip);
  Future<bool> updateTrip(Trip trip) => update(trips).replace(trip);
  Future<int> deleteTrip(int id) => (delete(trips)..where((t) => t.id.equals(id))).go();
}
