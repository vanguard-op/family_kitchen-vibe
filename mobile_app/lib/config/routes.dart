import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/kingdom_setup_screen.dart';
import '../screens/allergy_setup_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/inventory_add_screen.dart';
import '../screens/member_management_screen.dart';

/// App routes
const String routeSplash = '/';
const String routeLogin = '/login';
const String routeSignup = '/signup';
const String routeHome = '/home';
const String routeKingdomSetup = '/kingdom-setup';
const String routeAllergySetup = '/allergy-setup';
const String routeInventory = '/inventory';
const String routeInventoryAdd = '/inventory/add';
const String routeMembers = '/members';

/// Route map for named navigation
final Map<String, WidgetBuilder> appRoutes = {
  routeLogin: (_) => const LoginScreen(),
  routeSignup: (_) => const SignupScreen(),
  routeHome: (_) => const HomeScreen(),
  routeKingdomSetup: (_) => const KingdomSetupScreen(),
  routeAllergySetup: (_) => const AllergySetupScreen(),
  routeInventory: (_) => const InventoryScreen(),
  routeInventoryAdd: (_) => const InventoryAddScreen(),
  routeMembers: (_) => const MemberManagementScreen(),
};
