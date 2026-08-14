import 'package:drift/drift.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/tables/pahabilins.dart';

part 'pahabilin_dao.g.dart';

@DriftAccessor(tables: [Pahabilins])
class PahabilinDao extends DatabaseAccessor<AppDatabase> with _$PahabilinDaoMixin {
  PahabilinDao(super.db);

  Stream<List<Pahabilin>> watchPahabilinsForTrip(int tripId) {
    return (select(pahabilins)..where((p) => p.tripId.equals(tripId))..orderBy([(p) => OrderingTerm.desc(p.createdAt)])).watch();
  }

  Future<int> insertPahabilin(PahabilinsCompanion pahabilin) {
    return into(pahabilins).insert(pahabilin);
  }

  Future<bool> updatePahabilin(Pahabilin pahabilin) {
    return update(pahabilins).replace(pahabilin);
  }

  Future<int> deletePahabilin(int id) {
    return (delete(pahabilins)..where((p) => p.id.equals(id))).go();
  }
}
