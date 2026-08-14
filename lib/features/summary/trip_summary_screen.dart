import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ambagan_trip/core/theme/app_colors.dart';
import 'package:ambagan_trip/core/theme/app_text_styles.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/features/participants/participant_repository.dart';
import 'package:ambagan_trip/features/expenses/expense_repository.dart';

class TripSummaryScreen extends ConsumerWidget {
  final int tripId;

  const TripSummaryScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantRepositoryProvider).watchParticipantsForTrip(tripId);
    final expensesAsync = ref.watch(expenseRepositoryProvider).watchExpensesForTrip(tripId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Summary'),
      ),
      body: participantsAsync.when(
        data: (participants) {
          return expensesAsync.when(
            data: (expenses) {
              return _buildSummary(context, participants, expenses);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, List<Participant> participants, List<Expense> expenses) {
    double totalGroupExpenses = 0.0;
    
    // Map to keep track of how much each participant paid out of pocket for the group
    final outOfPocketPayments = <int, double>{};
    for (var p in participants) {
      outOfPocketPayments[p.id] = 0.0;
    }

    for (var e in expenses) {
      totalGroupExpenses += e.amount;
      if (e.paidById != null && outOfPocketPayments.containsKey(e.paidById)) {
        outOfPocketPayments[e.paidById!] = outOfPocketPayments[e.paidById!]! + e.amount;
      }
    }

    double totalExpected = participants.fold(0.0, (sum, p) => sum + p.expectedContribution);
    double totalCollected = participants.fold(0.0, (sum, p) => sum + p.amountPaid);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOverviewCard(totalGroupExpenses, totalExpected, totalCollected),
          const SizedBox(height: 24),
          const Text('SETTLEMENT / BALANCES', style: AppTextStyles.secondary),
          const SizedBox(height: 12),
          ...participants.map((p) {
            double outOfPocket = outOfPocketPayments[p.id] ?? 0.0;
            double totalContributed = p.amountPaid + outOfPocket;
            double balance = totalContributed - p.expectedContribution;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.name, style: AppTextStyles.cardTitle),
                        _buildBalanceBadge(balance),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Expected', style: TextStyle(color: Colors.grey)),
                        Text('₱${p.expectedContribution.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ambagan Paid', style: TextStyle(color: Colors.grey)),
                        Text('₱${p.amountPaid.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Paid for Group (Expenses)', style: TextStyle(color: Colors.grey)),
                        Text('₱${outOfPocket.toStringAsFixed(2)}'),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Contributed', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('₱${totalContributed.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(double totalExpenses, double totalExpected, double totalCollected) {
    return Card(
      color: AppColors.primaryLight,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('TOTAL TRIP EXPENSES', style: AppTextStyles.secondary),
            Text('₱${totalExpenses.toStringAsFixed(2)}', style: AppTextStyles.largeCurrency.copyWith(color: AppColors.primaryGreen)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Target Budget', style: AppTextStyles.secondary),
                    Text('₱${totalExpected.toStringAsFixed(2)}', style: AppTextStyles.cardTitle),
                  ],
                ),
                Column(
                  children: [
                    const Text('Cash in Pot', style: AppTextStyles.secondary),
                    Text('₱${totalCollected.toStringAsFixed(2)}', style: AppTextStyles.cardTitle),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceBadge(double balance) {
    if (balance == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
        child: const Text('Settled', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      );
    } else if (balance > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(16)),
        child: Text('Receives ₱${balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(16)),
        child: Text('Owes ₱${balance.abs().toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      );
    }
  }
}
