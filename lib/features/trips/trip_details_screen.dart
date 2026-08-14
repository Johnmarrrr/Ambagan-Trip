import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ambagan_trip/core/theme/app_text_styles.dart';
import 'package:ambagan_trip/core/theme/app_colors.dart';
import 'package:ambagan_trip/database/app_database.dart';
import 'package:ambagan_trip/features/trips/trip_repository.dart';
import 'package:ambagan_trip/features/participants/participant_repository.dart';
import 'package:ambagan_trip/features/expenses/expense_repository.dart';
import 'package:ambagan_trip/features/food/food_repository.dart';

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
                _ExpensesTab(tripId: trip.id),
                _FoodTab(tripId: trip.id),
                _MoreTab(tripId: trip.id),
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

class _ExpensesTab extends ConsumerWidget {
  final int tripId;

  const _ExpensesTab({required this.tripId});

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) async {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    String selectedCategory = 'Others';
    int? selectedPaidById;
    
    // Fetch participants for the dropdown
    final participants = await ref.read(participantRepositoryProvider).watchParticipantsForTrip(tripId).first;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Expense'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description (e.g., Gas, Dinner)'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: amountController,
                        decoration: const InputDecoration(labelText: 'Amount (₱)'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: ['Transport', 'Accommodation', 'Food', 'Activities', 'Others']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedCategory = v!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int?>(
                        initialValue: selectedPaidById,
                        decoration: const InputDecoration(labelText: 'Paid By (Optional)'),
                        items: [
                          const DropdownMenuItem<int?>(value: null, child: Text('Shared / Shared Pot')),
                          ...participants.map((p) => DropdownMenuItem<int?>(value: p.id, child: Text(p.name))),
                        ],
                        onChanged: (v) => setState(() => selectedPaidById = v),
                      ),
                    ],
                  ),
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
                      final description = descriptionController.text;
                      final amount = double.parse(amountController.text);
                      
                      final expense = ExpensesCompanion.insert(
                        tripId: tripId,
                        category: selectedCategory,
                        description: description,
                        amount: amount,
                        paidById: drift.Value(selectedPaidById),
                      );

                      await ref.read(expenseRepositoryProvider).addExpense(expense);
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
    final expensesAsync = ref.watch(expenseRepositoryProvider).watchExpensesForTrip(tripId);

    return Scaffold(
      body: StreamBuilder(
        stream: expensesAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data ?? [];
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No expenses yet', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  const Text('Record your trip spending here.', style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddExpenseDialog(context, ref),
                    child: const Text('+ Add Expense'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  title: Text(expense.description, style: AppTextStyles.cardTitle),
                  subtitle: Text(expense.category),
                  trailing: Text('₱${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Transport': return Icons.directions_car;
      case 'Accommodation': return Icons.hotel;
      case 'Food': return Icons.restaurant;
      case 'Activities': return Icons.local_activity;
      default: return Icons.receipt;
    }
  }
}

class _FoodTab extends ConsumerWidget {
  final int tripId;

  const _FoodTab({required this.tripId});

  void _showAddFoodDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedMeal = 'Breakfast';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Meal'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Dish Name (e.g., Adobo)'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedMeal,
                      decoration: const InputDecoration(labelText: 'Meal Type'),
                      items: ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedMeal = v!),
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
                      final food = FoodsCompanion.insert(
                        tripId: tripId,
                        name: name,
                        mealType: selectedMeal,
                      );
                      await ref.read(foodRepositoryProvider).addFood(food);
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
    final foodsAsync = ref.watch(foodRepositoryProvider).watchFoodsForTrip(tripId);

    return Scaffold(
      body: StreamBuilder(
        stream: foodsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final foods = snapshot.data ?? [];
          if (foods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No meals planned yet', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  const Text('Plan your menu for the trip.', style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddFoodDialog(context, ref),
                    child: const Text('+ Add Meal'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: foods.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final food = foods[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.restaurant_menu, color: AppColors.primaryGreen),
                  ),
                  title: Text(food.name, style: AppTextStyles.cardTitle),
                  subtitle: Text(food.mealType),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/trips/$tripId/food/${food.id}');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFoodDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MoreTab extends StatelessWidget {
  final int tripId;

  const _MoreTab({required this.tripId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.shopping_cart, color: AppColors.primaryGreen),
            title: const Text('Shopping List', style: AppTextStyles.cardTitle),
            subtitle: const Text('General trip items & supplies'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/trips/$tripId/shopping-list');
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.favorite, color: Colors.pink),
            title: const Text('Mga Pahabilin', style: AppTextStyles.cardTitle),
            subtitle: const Text('Personal requests & pasalubong'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/trips/$tripId/pahabilin');
            },
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calculate, color: Colors.orange),
            title: const Text('Trip Summary', style: AppTextStyles.cardTitle),
            subtitle: const Text('Who owes who / Balances'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Phase 6
            },
          ),
        ),
      ],
    );
  }
}
