import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ambagan_trip/core/theme/app_text_styles.dart';
import 'package:ambagan_trip/features/trips/trip_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTripsAsync = ref.watch(tripRepositoryProvider).watchActiveTrips();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good morning, \nPlanner! 👋',
                style: AppTextStyles.pageTitle,
              ),
              const SizedBox(height: 32),
              const Text(
                'YOUR ACTIVE TRIP',
                style: AppTextStyles.secondary,
              ),
              const SizedBox(height: 16),
              StreamBuilder(
                stream: activeTripsAsync,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final trips = snapshot.data ?? [];
                  if (trips.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  final activeTrip = trips.first;
                  return _buildActiveTripCard(context, activeTrip);
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Quick Actions',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/trips/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('New Trip'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'No trips yet',
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Start planning your first trip with your kasama.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/trips/create'),
              child: const Text('+ Create New Trip'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTripCard(BuildContext context, dynamic trip) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/trips/${trip.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trip.name, style: AppTextStyles.cardTitle),
              const SizedBox(height: 4),
              Text(
                trip.location ?? 'No location',
                style: AppTextStyles.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                '₱${trip.estimatedBudget.toStringAsFixed(2)}',
                style: AppTextStyles.largeCurrency,
              ),
              const Text('Estimated Budget', style: AppTextStyles.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
