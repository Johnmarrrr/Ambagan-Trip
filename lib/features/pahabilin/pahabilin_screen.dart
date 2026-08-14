import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ambagan_trip/core/theme/app_colors.dart';
import 'package:ambagan_trip/core/theme/app_text_styles.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/features/pahabilin/pahabilin_repository.dart';
import 'package:ambagan_trip/features/participants/participant_repository.dart';

class PahabilinScreen extends ConsumerWidget {
  final int tripId;

  const PahabilinScreen({super.key, required this.tripId});

  void _showAddPahabilinDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final costController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int? selectedParticipantId;

    final participants = await ref.read(participantRepositoryProvider).watchParticipantsForTrip(tripId).first;

    if (!context.mounted) return;

    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add participants first to assign a pahabilin.')),
      );
      return;
    }

    selectedParticipantId = participants.first.id;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Pahabilin'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: costController,
                      decoration: const InputDecoration(labelText: 'Estimated Cost (₱)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedParticipantId,
                      decoration: const InputDecoration(labelText: 'Requested By'),
                      items: participants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                      onChanged: (v) => setState(() => selectedParticipantId = v),
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
                    if (formKey.currentState!.validate() && selectedParticipantId != null) {
                      final name = nameController.text;
                      final cost = double.tryParse(costController.text) ?? 0.0;

                      final pahabilin = PahabilinsCompanion.insert(
                        tripId: tripId,
                        participantId: selectedParticipantId!,
                        itemName: name,
                        estimatedCost: drift.Value(cost),
                      );

                      await ref.read(pahabilinRepositoryProvider).addPahabilin(pahabilin);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pahabilinsAsync = ref.watch(pahabilinRepositoryProvider).watchPahabilinsForTrip(tripId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mga Pahabilin'),
      ),
      body: StreamBuilder(
        stream: pahabilinsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pahabilins = snapshot.data ?? [];
          if (pahabilins.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No pahabilin yet', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  const Text('Track personal requests from kasamas.', style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddPahabilinDialog(context, ref),
                    child: const Text('+ Add Pahabilin'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pahabilins.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final pahabilin = pahabilins[index];
              return CheckboxListTile(
                title: Text(pahabilin.itemName, style: AppTextStyles.cardTitle),
                subtitle: Text('Est. Cost: ₱${pahabilin.estimatedCost.toStringAsFixed(2)}'),
                value: pahabilin.isBought,
                activeColor: AppColors.primaryGreen,
                onChanged: (bool? value) {
                  if (value != null) {
                    final updated = pahabilin.copyWith(isBought: value);
                    ref.read(pahabilinRepositoryProvider).updatePahabilin(updated);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPahabilinDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
