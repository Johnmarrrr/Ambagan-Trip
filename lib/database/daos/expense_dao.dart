import 'package:drift/drift.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/database/tables/expenses.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  Stream<List<Expense>> watchExpensesForTrip(int tripId) {
    return (select(expenses)..where((e) => e.tripId.equals(tripId))..orderBy([(e) => OrderingTerm.desc(e.expenseDate)])).watch();
  }

  Future<int> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  Future<bool> updateExpense(Expense expense) {
    return update(expenses).replace(expense);
  }

  Future<int> deleteExpense(int id) {
    return (delete(expenses)..where((e) => e.id.equals(id))).go();
  }
}
