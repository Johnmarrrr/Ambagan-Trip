import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ambagan_trip/core/theme/app_colors.dart';
import 'package:ambagan_trip/core/theme/app_text_styles.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/features/food/ingredient_repository.dart';

class FoodDetailsScreen extends ConsumerWidget {
  final int tripId;
  final int foodId;

  const FoodDetailsScreen({super.key, required this.tripId, required this.foodId});

  void _showAddIngredientDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Ingredient'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Ingredient Name (e.g., Pork)'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: qtyController,
                  decoration: const InputDecoration(labelText: 'Quantity (e.g., 1kg)'),
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
                    foodId: drift.Value(foodId),
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
    final ingredientsAsync = ref.watch(ingredientRepositoryProvider).watchIngredientsForFood(foodId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
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
                  const Text('No ingredients yet', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  const Text('Add what you need for this meal.', style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddIngredientDialog(context, ref),
                    child: const Text('+ Add Ingredient'),
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
