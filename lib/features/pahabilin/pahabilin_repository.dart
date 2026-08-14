import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/database_provider.dart';

final pahabilinRepositoryProvider = Provider<PahabilinRepository>((ref) {
  return PahabilinRepository(ref.watch(databaseProvider));
});

class PahabilinRepository {
  final AppDatabase _db;

  PahabilinRepository(this._db);

  Stream<List<Pahabilin>> watchPahabilinsForTrip(int tripId) {
    return _db.pahabilinDao.watchPahabilinsForTrip(tripId);
  }

  Future<int> addPahabilin(PahabilinsCompanion pahabilin) {
    return _db.pahabilinDao.insertPahabilin(pahabilin);
  }

  Future<bool> updatePahabilin(Pahabilin pahabilin) {
    return _db.pahabilinDao.updatePahabilin(pahabilin);
  }

  Future<int> deletePahabilin(int id) {
    return _db.pahabilinDao.deletePahabilin(id);
  }
}
