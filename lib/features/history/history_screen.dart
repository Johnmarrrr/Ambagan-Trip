import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ambagan_trip/core/theme/app_text_styles.dart';
import 'package:ambagan_trip/features/trips/trip_repository.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedTripsAsync = ref.watch(tripRepositoryProvider).watchCompletedTrips();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: StreamBuilder(
        stream: completedTripsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final trips = snapshot.data ?? [];
          if (trips.isEmpty) {
            return const Center(
              child: Text('No completed trips yet', style: AppTextStyles.body),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                child: ListTile(
                  title: Text(trip.name, style: AppTextStyles.cardTitle),
                  subtitle: Text(trip.location ?? 'No location'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/trips/${trip.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
