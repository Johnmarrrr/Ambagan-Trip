import 'package:drift/drift.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/tables/ingredients.dart';

part 'ingredient_dao.g.dart';

@DriftAccessor(tables: [Ingredients])
class IngredientDao extends DatabaseAccessor<AppDatabase> with _$IngredientDaoMixin {
  IngredientDao(super.db);

  Stream<List<Ingredient>> watchIngredientsForTrip(int tripId) {
    return (select(ingredients)..where((i) => i.tripId.equals(tripId))).watch();
  }

  Stream<List<Ingredient>> watchIngredientsForFood(int foodId) {
    return (select(ingredients)..where((i) => i.foodId.equals(foodId))).watch();
  }

  Future<int> insertIngredient(IngredientsCompanion ingredient) {
    return into(ingredients).insert(ingredient);
  }

  Future<bool> updateIngredient(Ingredient ingredient) {
    return update(ingredients).replace(ingredient);
  }

  Future<int> deleteIngredient(int id) {
    return (delete(ingredients)..where((i) => i.id.equals(id))).go();
  }
}
