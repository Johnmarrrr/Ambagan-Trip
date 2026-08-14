import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/database_provider.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(ref.watch(databaseProvider));
});

class TripRepository {
  final AppDatabase _db;

  TripRepository(this._db);

  Stream<List<Trip>> watchAllTrips() => _db.tripDao.watchAllTrips();
  Stream<List<Trip>> watchActiveTrips() => _db.tripDao.watchActiveTrips();
  Stream<List<Trip>> watchCompletedTrips() => _db.tripDao.watchCompletedTrips();
  Stream<Trip> watchTrip(int id) => _db.tripDao.watchTrip(id);
  
  Future<int> createTrip(TripsCompanion trip) => _db.tripDao.insertTrip(trip);
  Future<bool> updateTrip(Trip trip) => _db.tripDao.updateTrip(trip);
  Future<int> deleteTrip(int id) => _db.tripDao.deleteTrip(id);
}
