import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:ambagan_trip/features/trips/trip_repository.dart';
import 'package:ambagan_trip/features/participants/participant_repository.dart';
import 'package:ambagan_trip/features/expenses/expense_repository.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref);
});

class ExportService {
  final Ref _ref;

  ExportService(this._ref);

  Future<void> exportCsv(int tripId) async {
    final trip = await _ref.read(tripRepositoryProvider).watchTrip(tripId).first;
    
    final participantsStream = _ref.read(participantRepositoryProvider).watchParticipantsForTrip(tripId);
    final participants = await participantsStream.first;
    
    final expensesStream = _ref.read(expenseRepositoryProvider).watchExpensesForTrip(tripId);
    final expenses = await expensesStream.first;
    
    List<List<dynamic>> rows = [];
    
    // Header
    rows.add(['Ambagan Trip Summary', trip.name]);
    rows.add(['Date', trip.startDate.toIso8601String()]);
    rows.add([]);
    
    // Participants
    rows.add(['PARTICIPANTS']);
    rows.add(['Name', 'Expected Contribution', 'Amount Paid', 'Due/Settled']);
    for (var p in participants) {
      final due = p.expectedContribution - p.amountPaid;
      rows.add([p.name, p.expectedContribution, p.amountPaid, due > 0 ? '$due Due' : 'Settled']);
    }
    
    rows.add([]);
    
    // Expenses
    rows.add(['EXPENSES']);
    rows.add(['Description', 'Amount', 'Category', 'Date']);
    double totalExpenses = 0.0;
    for (var e in expenses) {
      rows.add([e.description, e.amount, e.category, e.expenseDate.toIso8601String()]);
      totalExpenses += e.amount;
    }
    rows.add(['Total Expenses', totalExpenses]);
    
    String csvStr = csv.encode(rows);
    
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/trip_${trip.id}_summary.csv');
    await file.writeAsString(csvStr);
    
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], text: '${trip.name} CSV Summary');
  }

  Future<void> exportPdf(int tripId) async {
    final trip = await _ref.read(tripRepositoryProvider).watchTrip(tripId).first;
    
    final participantsStream = _ref.read(participantRepositoryProvider).watchParticipantsForTrip(tripId);
    final participants = await participantsStream.first;
    
    final expensesStream = _ref.read(expenseRepositoryProvider).watchExpensesForTrip(tripId);
    final expenses = await expensesStream.first;
    
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          double totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
          
          return [
            pw.Header(level: 0, child: pw.Text('Ambagan Trip Summary: ${trip.name}')),
            pw.Text('Date: ${trip.startDate.toIso8601String()}', style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            
            pw.Header(level: 1, child: pw.Text('Participants')),
            pw.TableHelper.fromTextArray(
              context: context,
              data: [
                ['Name', 'Expected', 'Paid', 'Due'],
                ...participants.map((p) {
                  final due = p.expectedContribution - p.amountPaid;
                  return [
                    p.name, 
                    'PHP ${p.expectedContribution.toStringAsFixed(2)}',
                    'PHP ${p.amountPaid.toStringAsFixed(2)}',
                    due > 0 ? 'PHP ${due.toStringAsFixed(2)} Due' : 'Settled'
                  ];
                })
              ],
            ),
            
            pw.SizedBox(height: 20),
            pw.Header(level: 1, child: pw.Text('Expenses')),
            pw.TableHelper.fromTextArray(
              context: context,
              data: [
                ['Description', 'Category', 'Amount'],
                ...expenses.map((e) => [
                  e.description, 
                  e.category, 
                  'PHP ${e.amount.toStringAsFixed(2)}'
                ]),
                ['TOTAL', '', 'PHP ${totalExpenses.toStringAsFixed(2)}']
              ],
            ),
          ];
        }
      )
    );
    
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/trip_${trip.id}_summary.pdf');
    await file.writeAsBytes(await pdf.save());
    
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], text: '${trip.name} PDF Summary');
  }
}
