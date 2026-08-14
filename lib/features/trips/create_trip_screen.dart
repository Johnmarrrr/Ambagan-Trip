import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/features/trips/trip_repository.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _location = '';
  double _budget = 0.0;

  void _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final trip = TripsCompanion(
        name: drift.Value(_name),
        location: drift.Value(_location),
        estimatedBudget: drift.Value(_budget),
        startDate: drift.Value(DateTime.now()),
      );

      await ref.read(tripRepositoryProvider).createTrip(trip);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Trip'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Trip Name', hintText: 'Yambo Lake'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _name = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location (Optional)'),
                onSaved: (value) => _location = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Estimated Budget'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  if (double.parse(value) < 0) return 'Cannot be negative';
                  return null;
                },
                onSaved: (value) => _budget = double.tryParse(value ?? '0') ?? 0,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTrip,
                      child: const Text('Create Trip'),
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
}
