---
description: "Use when building Flutter UI screens, widgets, themes, or navigation for any mobile app. Enforces modern cool design, go_router, flutter_bloc, signals, google_fonts, font_awesome_flutter, and fluid animation patterns."
name: "Mobile App — Modern UI/UX"
applyTo: "mobile_app/**"
---

# Mobile App — Modern UI/UX Standards

## Design Philosophy

Build with a **premium aesthetic** suited to the project's brand — rich accents on deep or light neutral surfaces, generous whitespace, and micro-interactions that feel alive. Every screen should feel polished: fluid transitions, purposeful animations, and typographic hierarchy that guides the eye.

Choose a coherent color story for each project (e.g. warm-dark, cool-light, vibrant-saturated) and encode it in `AppColors`. The patterns in this instruction are universal regardless of palette.

> Rule: If it looks "default Flutter", it's not done yet.

---

## Approved Package Stack

Add these to `pubspec.yaml` before coding. Do NOT use packages outside this list without justification.

### Navigation
```yaml
go_router: ^14.0.0          # Declarative, type-safe routing
```

### State Management
```yaml
flutter_bloc: ^8.1.6        # BLoC/Cubit for complex state
bloc: ^8.1.4
signals_flutter: ^5.5.0     # Fine-grained reactivity for UI state
```

### UI & Typography
```yaml
google_fonts: ^6.1.0        # Typography
font_awesome_flutter: ^10.7.0  # Icon set
flutter_animate: ^4.5.0     # Declarative animations
gap: ^3.0.1                 # Semantic spacing
shimmer: ^3.0.0             # Skeleton loaders
cached_network_image: ^3.3.0
```

### Utilities (add as needed)
```yaml
dio: ^5.3.0                 # HTTP client
shared_preferences: ^2.2.0  # Key-value local storage
connectivity_plus: ^7.0.0   # Network status
intl: ^0.19.0               # Formatting / i18n
```

---

## Project Structure

```
lib/
  main.dart
  app.dart                  # MaterialApp.router entry
  router/
    app_router.dart         # GoRouter definition (all routes here)
                            # No routes.dart — route names live on each screen
  theme/
    app_theme.dart          # ThemeData light + dark
    app_colors.dart         # Color palette tokens
    app_text_styles.dart    # TextStyle tokens
    app_sizes.dart          # Spacing/radius constants
  features/                 # Feature-first organization
    auth/
      bloc/                 # AuthBloc, AuthState, AuthEvent
      screens/
      widgets/
    <feature_a>/             # One folder per domain feature
      bloc/                 # BLoC for complex state, cubit/ for simple
      screens/
      widgets/
    <feature_b>/
      ...
  widgets/                  # App-wide shared widgets
    buttons/
    cards/
    inputs/
    loaders/
  utils/
```

---

## Theming

### Color Palette (`app_colors.dart`)

Define tokens that map the project's brand to semantic roles. Replace the hex values below with the project's actual palette.

```dart
abstract final class AppColors {
  // --- Brand (replace with project palette) ---
  static const primary     = Color(0xFF000000);   // Primary action color
  static const primaryDark = Color(0xFF000000);   // Darker tint of primary
  static const accent      = Color(0xFF000000);   // Secondary highlight

  // --- Surfaces ---
  static const surface     = Color(0xFF000000);   // App background
  static const surfaceAlt  = Color(0xFF000000);   // Slightly offset surface
  static const card        = Color(0xFF000000);   // Card background

  // --- Neutral ---
  static const textPrimary   = Color(0xFF000000);
  static const textSecondary = Color(0xFF000000);
  static const divider       = Color(0xFF000000);

  // --- Semantic (keep consistent across projects) ---
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error   = Color(0xFFEF5350);
}
```

**Dark theme example** (warm-dark): primary `0xFFE8793A`, surface `0xFF1A1A2E`, card `0xFF0F3460`  
**Light theme example** (cool-minimal): primary `0xFF3A7BD5`, surface `0xFFF5F7FA`, card `0xFFFFFFFF`

### Typography (`app_text_styles.dart`)

Always use **Google Fonts**. Never use the default `fontFamily: 'Roboto'` override in `ThemeData`.

```dart
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static final displayLarge  = GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700);
  static final displayMedium = GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600);
  static final headlineLarge = GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600);
  static final titleMedium   = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500);
  static final bodyLarge     = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400);
  static final bodyMedium    = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400);
  static final labelLarge    = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5);
  static final caption       = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400);
}
```

### ThemeData (`app_theme.dart`)

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: TextTheme(
      displayLarge:  AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary),
      titleMedium:   AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
      bodyLarge:     AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      bodyMedium:    AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      labelLarge:    AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
  );

  static ThemeData get light => dark.copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F6F2),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: const Color(0xFFF8F6F2),
      onSurface: const Color(0xFF1A1A2E),
    ),
  );
}
```

---

## Navigation (GoRouter)

### Route name on each screen

Every screen declares its own `route` name as a `static const String`. Path and query parameter keys are also declared on the screen, prefixed with `path` or `query`.

```dart
// features/auth/screens/login_screen.dart
class LoginScreen extends StatelessWidget {
  static const String route = 'login';   // Used as GoRoute name

  const LoginScreen({super.key});
  // ...
}

// features/item/screens/detail_screen.dart
class DetailScreen extends StatelessWidget {
  static const String route    = 'detail';
  static const String pathId   = 'id';            // path parameter: /detail/:id
  static const String queryTab = 'tab';           // query parameter: ?tab=info

  final String id;
  final String? tab;
  const DetailScreen({super.key, required this.id, this.tab});
  // ...
}
```

### `router/app_router.dart`

Every `GoRoute` sets both `name` (from the screen's `route` constant) and `path` (URL string). Paths are an implementation detail — no other file references them as strings.

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/bloc/auth_bloc.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  // Auth guard — adapt condition to the project's auth BLoC/Cubit
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;
    final isAuthRoute = state.matchedLocation == '/login'
        || state.matchedLocation == '/signup';

    if (!isLoggedIn && !isAuthRoute && state.matchedLocation != '/') {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(name: SplashScreen.route, path: '/',       builder: (_, __) => const SplashScreen()),
    GoRoute(name: LoginScreen.route,  path: '/login',  builder: (_, __) => const LoginScreen()),
    GoRoute(name: SignupScreen.route, path: '/signup', builder: (_, __) => const SignupScreen()),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(name: HomeScreen.route, path: '/home', builder: (_, __) => const HomeScreen()),
        // Add project-specific routes here.
        // GoRoute(
        //   name: FeatureAScreen.route,
        //   path: '/home/feature-a',
        //   builder: (_, __) => const FeatureAScreen(),
        // ),
        // Route with path + query parameters:
        // GoRoute(
        //   name: DetailScreen.route,
        //   path: '/home/feature-a/:${DetailScreen.pathId}',
        //   builder: (_, state) => DetailScreen(
        //     id:  state.pathParameters[DetailScreen.pathId]!,
        //     tab: state.uri.queryParameters[DetailScreen.queryTab],
        //   ),
        // ),
        // Use CustomTransitionPage for modal-style pushes:
        // GoRoute(
        //   name: DetailScreen.route,
        //   path: '/home/feature-a/:${DetailScreen.pathId}',
        //   pageBuilder: (_, state) => CustomTransitionPage(
        //     child: DetailScreen(id: state.pathParameters[DetailScreen.pathId]!),
        //     transitionsBuilder: (_, anim, __, child) =>
        //         SlideTransition(
        //           position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(anim),
        //           child: child,
        //         ),
        //   ),
        // ),
      ],
    ),
  ],
);
```

### Navigation usage

Always navigate by **name** using the screen's `route` constant. Use the screen's `pathXxx` / `queryXxx` constants as parameter keys — never hardcode strings.

```dart
// Replace current stack
context.goNamed(HomeScreen.route);

// Push onto stack (back button returns)
context.pushNamed(SignupScreen.route);

// Pop
context.pop();

// With path parameters
context.goNamed(
  DetailScreen.route,
  pathParameters: {DetailScreen.pathId: item.id},
);

// With query parameters
context.goNamed(
  FeatureAScreen.route,
  queryParameters: {FeatureAScreen.queryFilter: 'active'},
);

// With extra (non-serializable in-memory data)
context.pushNamed(DetailScreen.route, extra: item);
```

---

## State Management

### BLoC — for complex async/auth state

Use sealed classes for exhaustive pattern matching on states. Name events as past-tense intentions, states as nouns.

```dart
// features/auth/bloc/auth_bloc.dart  (adapt for any feature)
sealed class AuthEvent {}
class AuthLoginRequested extends AuthEvent {
  final String email, password;
  AuthLoginRequested({required this.email, required this.password});
}
class AuthLogoutRequested extends AuthEvent {}

sealed class AuthState {}
class AuthInitial         extends AuthState {}
class AuthLoading         extends AuthState {}
class AuthAuthenticated   extends AuthState { final UserModel user; AuthAuthenticated(this.user); }
class AuthUnauthenticated extends AuthState {}
class AuthError           extends AuthState { final String message; AuthError(this.message); }

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repo.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  // ...
}
```

### Signals — for lightweight UI reactivity

Use `signals_flutter` for local ephemeral state: form visibility, toggle states, counters. Do **not** use BLoC for this.

```dart
import 'package:signals_flutter/signals_flutter.dart';

// Example: any screen with search + filter toggle
class ItemListScreen extends StatelessWidget {
  final _searchQuery = signal('');
  final _showFilters = signal(false);

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return Column(
        children: [
          SearchBar(onChanged: (v) => _searchQuery.value = v),
          if (_showFilters.value) const FilterPanel(),
          ItemList(query: _searchQuery.value),
        ],
      );
    });
  }
}
```

### Cubit — for simpler state machines (list + loading)

```dart
// Replace FeatureItems/FeatureState with project-specific names
class FeatureCubit extends Cubit<FeatureState> {
  FeatureCubit(this._repo) : super(FeatureInitial());

  Future<void> load() async {
    emit(FeatureLoading());
    try {
      final items = await _repo.getAll();
      emit(FeatureLoaded(items));
    } catch (e) {
      emit(FeatureError(e.toString()));
    }
  }
}
```

---

## Widget Patterns

### Spacing — use `Gap`, never `SizedBox` for whitespace

```dart
import 'package:gap/gap.dart';

Column(
  children: [
    Text('Title'),
    const Gap(16),
    Text('Body'),
    const Gap(8),
    ElevatedButton(...),
  ],
)
```

### Icons — use `FontAwesomeIcons`, not Material icons for feature icons

```dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

FaIcon(FontAwesomeIcons.kitchenSet, size: 24, color: AppColors.primary)
FaIcon(FontAwesomeIcons.utensils)
FaIcon(FontAwesomeIcons.boxesStacked)
FaIcon(FontAwesomeIcons.triangleExclamation)
```

Use Material icons only for standard navigation (back arrow, close, menu).

### Animations — use `flutter_animate`

```dart
import 'package:flutter_animate/flutter_animate.dart';

// Entrance animation on widget appearance
Card(...)
  .animate()
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.1, curve: Curves.easeOut);

// Staggered list items
ListView.builder(
  itemBuilder: (ctx, i) => ItemTile(item: items[i])
    .animate(delay: (i * 50).ms)
    .fadeIn()
    .slideX(begin: -0.05),
);
```

### Gradient Backgrounds

Screens should use subtle gradients, NOT flat scaffold colors:

```dart
Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.surface, AppColors.surfaceAlt],
    ),
  ),
  child: child,
)
```

### Glassmorphism Cards (for hero/featured content)

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: child,
    ),
  ),
)
```

---

## App Entry Point

Replace existing `main.dart` / `MaterialApp` with:

```dart
// app.dart — rename the class to match the project (e.g. MyProjectApp)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide top-level BLoCs that need to outlive individual screens
        BlocProvider(create: (_) => AuthBloc(AuthRepository())..add(AuthCheckRequested())),
      ],
      child: MaterialApp.router(
        title: 'App Title',           // Replace with project name
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,    // Override per project if needed
        routerConfig: appRouter,
      ),
    );
  }
}
```

---

## Anti-Patterns (Never Do These)

| Bad | Good |
|-----|------|
| `fontFamily: 'Roboto'` in ThemeData | `GoogleFonts.poppins(...)` in `AppTextStyles` |
| `Navigator.push(...)` | `context.pushNamed(ScreenClass.route)` |
| `context.go('/some/path')` hardcoded path | `context.goNamed(ScreenClass.route)` |
| `pathParameters: {'id': x}` raw string key | `pathParameters: {DetailScreen.pathId: x}` |
| Central `Routes` class with all names | `static const String route` on each screen |
| `SizedBox(height: 16)` for spacing | `Gap(16)` |
| `ChangeNotifierProvider` + Provider | `BlocProvider` + `flutter_bloc` |
| Hardcoded colors (`Colors.orange`) | `AppColors.primary` |
| Material `Icons.kitchen` for features | `FontAwesomeIcons.kitchenSet` |
| `setState` in large screens | Signals or Cubit |
| Plain `Column` for lists | `ListView.builder` with `.animate()` |
| `Text(s, style: TextStyle(...))` inline | `AppTextStyles.bodyMedium` token |

---

## Screen Checklist

Before submitting a screen, verify:

- [ ] Uses `AppColors` tokens — no raw `Colors.*` for brand colors
- [ ] Uses `AppTextStyles` — no inline `TextStyle(fontSize: ...)`
- [ ] Uses `Gap(n)` for spacing — no `SizedBox(height/width: n)`
- [ ] Uses `FaIcon` for feature icons — no `Icon(Icons.*)` for domain icons
- [ ] Has entrance animations via `flutter_animate`
- [ ] Loading states use `Shimmer` skeleton — no plain `CircularProgressIndicator` in full screens
- [ ] Navigation uses `context.goNamed` / `context.pushNamed` — no `Navigator.push`
- [ ] BLoC state emitted for async operations — no raw `try/catch` in widgets
- [ ] Gradient or textured background — no flat scaffold color on hero screens
