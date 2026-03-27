import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class FamilyKitchenApp extends StatelessWidget {
  const FamilyKitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AuthBloc(AuthRepository())..add(const AuthCheckRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Family Kitchen — The Royal Hearth',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
