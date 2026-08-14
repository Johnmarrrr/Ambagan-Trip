import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ambagan_trip/core/theme/app_colors.dart';
import 'package:ambagan_trip/core/theme/app_text_styles.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/features/food/ingredient_repository.dart';

class ShoppingListScreen extends ConsumerWidget {
  final int tripId;

  const ShoppingListScreen({super.key, required this.tripId});

  void _showAddIngredientDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Item to Shopping List'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name (e.g., Paper Plates)'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: qtyController,
                  decoration: const InputDecoration(labelText: 'Quantity (Optional)'),
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
                  final quantity = qtyController.text;

                  final ingredient = IngredientsCompanion.insert(
                    tripId: tripId,
                    name: name,
                    quantity: drift.Value(quantity.isNotEmpty ? quantity : null),
                  );

                  await ref.read(ingredientRepositoryProvider).addIngredient(ingredient);
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
    // We get all ingredients for the trip. 
    // For a real app we could filter general vs food-specific, 
    // but the user might want a unified shopping list here.
    final ingredientsAsync = ref.watch(ingredientRepositoryProvider).watchIngredientsForTrip(tripId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Shopping List'),
      ),
      body: StreamBuilder(
        stream: ingredientsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ingredients = snapshot.data ?? [];
          if (ingredients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Shopping list is empty', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  const Text('Add general items or food ingredients.', style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddIngredientDialog(context, ref),
                    child: const Text('+ Add Item'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ingredients.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              return CheckboxListTile(
                title: Text(ingredient.name, style: AppTextStyles.cardTitle),
                subtitle: ingredient.quantity != null ? Text(ingredient.quantity!) : null,
                value: ingredient.isBought,
                activeColor: AppColors.primaryGreen,
                onChanged: (bool? value) {
                  if (value != null) {
                    final updated = ingredient.copyWith(isBought: value);
                    ref.read(ingredientRepositoryProvider).updateIngredient(updated);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIngredientDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
