import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ambagan_trip/shared/widgets/app_scaffold.dart';
import 'package:ambagan_trip/features/home/home_screen.dart';
import 'package:ambagan_trip/features/trips/trips_screen.dart';
import 'package:ambagan_trip/features/history/history_screen.dart';
import 'package:ambagan_trip/features/settings/more_screen.dart';
import 'package:ambagan_trip/features/trips/create_trip_screen.dart';
import 'package:ambagan_trip/features/trips/trip_details_screen.dart';
import 'package:ambagan_trip/features/food/food_details_screen.dart';
import 'package:ambagan_trip/features/shopping/shopping_list_screen.dart';
import 'package:ambagan_trip/features/pahabilin/pahabilin_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/trips',
          builder: (context, state) => const TripsScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const MoreScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/trips/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateTripScreen(),
    ),
    GoRoute(
      path: '/trips/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TripDetailsScreen(tripId: id);
      },
    ),
    GoRoute(
      path: '/trips/:id/food/:foodId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['id']!);
        final foodId = int.parse(state.pathParameters['foodId']!);
        return FoodDetailsScreen(tripId: tripId, foodId: foodId);
      },
    ),
    GoRoute(
      path: '/trips/:id/shopping-list',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['id']!);
        return ShoppingListScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trips/:id/pahabilin',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['id']!);
        return PahabilinScreen(tripId: tripId);
      },
    ),
  ],
);
