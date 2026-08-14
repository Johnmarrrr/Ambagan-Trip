import 'package:drift/drift.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/tables/foods.dart';

part 'food_dao.g.dart';

@DriftAccessor(tables: [Foods])
class FoodDao extends DatabaseAccessor<AppDatabase> with _$FoodDaoMixin {
  FoodDao(super.db);

  Stream<List<Food>> watchFoodsForTrip(int tripId) {
    return (select(foods)..where((f) => f.tripId.equals(tripId))..orderBy([(f) => OrderingTerm.desc(f.createdAt)])).watch();
  }

  Future<int> insertFood(FoodsCompanion food) {
    return into(foods).insert(food);
  }

  Future<int> deleteFood(int id) {
    return (delete(foods)..where((f) => f.id.equals(id))).go();
  }
}
