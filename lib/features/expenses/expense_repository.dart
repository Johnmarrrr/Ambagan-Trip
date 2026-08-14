import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/database_provider.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(databaseProvider));
});

class ExpenseRepository {
  final AppDatabase _db;

  ExpenseRepository(this._db);

  Stream<List<Expense>> watchExpensesForTrip(int tripId) {
    return _db.expenseDao.watchExpensesForTrip(tripId);
  }

  Future<int> addExpense(ExpensesCompanion expense) {
    return _db.expenseDao.insertExpense(expense);
  }

  Future<bool> updateExpense(Expense expense) {
    return _db.expenseDao.updateExpense(expense);
  }

  Future<int> deleteExpense(int id) {
    return _db.expenseDao.deleteExpense(id);
  }
}
