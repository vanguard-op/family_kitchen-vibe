import 'package:flutter/material.dart';

/// App routes
const String routeSplash = '/';
const String routeLogin = '/login';
const String routeSignup = '/signup';
const String routeHome = '/home';
const String routeKingdomSetup = '/kingdom-setup';
const String routeAllergySetup = '/allergy-setup';
const String routeInventory = '/inventory';
const String routeInventoryAdd = '/inventory-add';
const String routeChefMode = '/chef-mode';
const String routeMemberManagement = '/members';

/// Route map for named navigation
final Map<String, WidgetBuilder> appRoutes = {
  routeLogin: (_) => const LoginScreen(),
  routeSignup: (_) => const SignupScreen(),
  routeHome: (_) => const HomeScreen(),
  routeKingdomSetup: (_) => const KingdomSetupScreen(),
  routeAllergySetup: (_) => const AllergySetupScreen(),
  routeInventory: (_) => const InventoryScreen(),
  routeInventoryAdd: (_) => const InventoryAddScreen(),
  routeChefMode: (_) => const ChefModeScreen(),
  routeMemberManagement: (_) => const MemberManagementScreen(),
};

// Placeholder screens (to be implemented)
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class KingdomSetupScreen extends StatelessWidget {
  const KingdomSetupScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class AllergySetupScreen extends StatelessWidget {
  const AllergySetupScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class InventoryAddScreen extends StatelessWidget {
  const InventoryAddScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class ChefModeScreen extends StatelessWidget {
  const ChefModeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MemberManagementScreen extends StatelessWidget {
  const MemberManagementScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Placeholder();
}
