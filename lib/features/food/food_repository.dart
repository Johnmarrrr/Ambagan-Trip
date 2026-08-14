import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/database_provider.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository(ref.watch(databaseProvider));
});

class FoodRepository {
  final AppDatabase _db;

  FoodRepository(this._db);

  Stream<List<Food>> watchFoodsForTrip(int tripId) {
    return _db.foodDao.watchFoodsForTrip(tripId);
  }

  Future<int> addFood(FoodsCompanion food) {
    return _db.foodDao.insertFood(food);
  }

  Future<int> deleteFood(int id) {
    return _db.foodDao.deleteFood(id);
  }
}
