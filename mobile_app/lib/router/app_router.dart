import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/home/cubit/home_cubit.dart';
import '../features/home/screens/home_screen.dart';
import '../features/inventory/cubit/inventory_cubit.dart';
import '../features/inventory/screens/inventory_screen.dart';
import '../features/inventory/screens/inventory_add_screen.dart';
import '../features/members/cubit/members_cubit.dart';
import '../features/members/screens/member_management_screen.dart';
import '../features/kingdom/cubit/kingdom_cubit.dart';
import '../features/kingdom/screens/kingdom_setup_screen.dart';
import '../features/allergy/cubit/allergy_cubit.dart';
import '../features/allergy/screens/allergy_setup_screen.dart';
import 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isOnAuth = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/';
    if (authState is AuthUnauthenticated && !isOnAuth) return '/login';
    return null;
  },
  routes: [
    GoRoute(
      name: AppRoutes.splash,
      path: '/',
      builder: (_, __) => const SplashScreen(),
      routes: [
        GoRoute(
          name: AppRoutes.login,
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          name: AppRoutes.signup,
          path: '/signup',
          builder: (_, __) => const SignupScreen(),
        ),
      ],
    ),
    GoRoute(
      name: AppRoutes.kingdomSetup,
      path: '/kingdom-setup',
      builder: (_, __) => BlocProvider(
        create: (_) => KingdomCubit(),
        child: const KingdomSetupScreen(),
      ),
    ),
    GoRoute(
      name: AppRoutes.home,
      path: '/home',
      builder: (_, __) => BlocProvider(
        create: (_) => HomeCubit(),
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      name: AppRoutes.inventory,
      path: '/inventory',
      builder: (_, __) => BlocProvider(
        create: (_) => InventoryCubit(),
        child: const InventoryScreen(),
      ),
      routes: [
        GoRoute(
          name: AppRoutes.inventoryAdd,
          path: 'add',
          builder: (context, __) => BlocProvider.value(
            value: context.read<InventoryCubit>(),
            child: const InventoryAddScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      name: AppRoutes.members,
      path: '/members',
      builder: (_, __) => BlocProvider(
        create: (_) => MembersCubit(),
        child: const MemberManagementScreen(),
      ),
    ),
    GoRoute(
      name: AppRoutes.allergySetup,
      path: '/allergy-setup',
      builder: (_, __) => BlocProvider(
        create: (_) => AllergyCubit(),
        child: const AllergySetupScreen(),
      ),
    ),
  ],
);
