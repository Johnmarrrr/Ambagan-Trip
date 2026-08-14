import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ambagan_trip/core/theme/app_text_styles.dart';
import 'package:ambagan_trip/features/trips/trip_repository.dart';

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
  final trip;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Ambagan Placeholder'));
  }
}
