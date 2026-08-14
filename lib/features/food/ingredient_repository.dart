import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/database_provider.dart';

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  return IngredientRepository(ref.watch(databaseProvider));
});

class IngredientRepository {
  final AppDatabase _db;

  IngredientRepository(this._db);

  Stream<List<Ingredient>> watchIngredientsForTrip(int tripId) {
    return _db.ingredientDao.watchIngredientsForTrip(tripId);
  }

  Stream<List<Ingredient>> watchIngredientsForFood(int foodId) {
    return _db.ingredientDao.watchIngredientsForFood(foodId);
  }

  Future<int> addIngredient(IngredientsCompanion ingredient) {
    return _db.ingredientDao.insertIngredient(ingredient);
  }

  Future<bool> updateIngredient(Ingredient ingredient) {
    return _db.ingredientDao.updateIngredient(ingredient);
  }

  Future<int> deleteIngredient(int id) {
    return _db.ingredientDao.deleteIngredient(id);
  }
}
