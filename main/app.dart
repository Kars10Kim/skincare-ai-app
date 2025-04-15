import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection_container.dart';
import '../features/history/presentation/cubit/favorites_cubit.dart';
import '../features/history/presentation/cubit/history_cubit.dart';
import '../features/shell/app_shell.dart';

/// Main app
class SkincareScannerApp extends StatelessWidget {
  /// Create main app
  const SkincareScannerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HistoryCubit>(
          create: (context) => sl<HistoryCubit>(),
        ),
        BlocProvider<FavoritesCubit>(
          create: (context) => sl<FavoritesCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Skincare Scanner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}