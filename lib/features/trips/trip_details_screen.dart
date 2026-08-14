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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Overview'),
      ),
      body: StreamBuilder(
        stream: tripAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Trip not found'));
          }

          final trip = snapshot.data!;
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
        },
      ),
    );
  }
}
