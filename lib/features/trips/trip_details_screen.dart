import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ambagan_trip/core/theme/app_text_styles.dart';
import 'package:ambagan_trip/core/theme/app_colors.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/features/trips/trip_repository.dart';
import 'package:ambagan_trip/features/participants/participant_repository.dart';

class TripDetailsScreen extends ConsumerWidget {
  final int tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripRepositoryProvider).watchTrip(tripId);

    return StreamBuilder(
      stream: tripAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('Trip not found')));
        }

        final trip = snapshot.data!;

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: Text(trip.name),
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Ambagan'),
                  Tab(text: 'Expenses'),
                  Tab(text: 'Food'),
                  Tab(text: 'More'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _OverviewTab(trip: trip),
                _AmbaganTab(tripId: trip.id),
                const Center(child: Text('Expenses')),
                const Center(child: Text('Food')),
                const Center(child: Text('More')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Trip trip;

  const _OverviewTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trip.name, style: AppTextStyles.pageTitle),
          const SizedBox(height: 4),
          Text(trip.location ?? '', style: AppTextStyles.secondary),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('TOTAL COST', style: AppTextStyles.secondary),
                  Text('₱${trip.estimatedBudget.toStringAsFixed(2)}', style: AppTextStyles.largeCurrency),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('COLLECTED', style: AppTextStyles.secondary),
                          Text('₱0.00', style: AppTextStyles.cardTitle.copyWith(color: Colors.green)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('REMAINING', style: AppTextStyles.secondary),
                          Text('₱${trip.estimatedBudget.toStringAsFixed(2)}', style: AppTextStyles.cardTitle.copyWith(color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbaganTab extends ConsumerWidget {
  final int tripId;

  const _AmbaganTab({required this.tripId});

  void _showAddParticipantDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final contributionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Participant'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contributionController,
                  decoration: const InputDecoration(labelText: 'Expected Contribution'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final name = nameController.text;
                  final contribution = double.tryParse(contributionController.text) ?? 0.0;
                  
                  final participant = ParticipantsCompanion.insert(
                    tripId: tripId,
                    name: name,
                    expectedContribution: drift.Value(contribution),
                  );

                  await ref.read(participantRepositoryProvider).addParticipant(participant);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantRepositoryProvider).watchParticipantsForTrip(tripId);

    return Scaffold(
      body: StreamBuilder(
        stream: participantsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final participants = snapshot.data ?? [];
          if (participants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No participants yet', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  const Text('Add members to start collecting ambagan.', style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddParticipantDialog(context, ref),
                    child: const Text('+ Add Participant'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: participants.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final participant = participants[index];
              return Card(
                child: ListTile(
                  title: Text(participant.name, style: AppTextStyles.cardTitle),
                  subtitle: Text('Expected: ₱${participant.expectedContribution.toStringAsFixed(2)}'),
                  trailing: const Text('₱0.00 Due', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddParticipantDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
