import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';

/// Raíz de la aplicación.
///
/// Aquí se inyectan las dependencias que el resto del árbol necesita:
/// - `RepositoryProvider<WalletRepository>`: capa de datos disponible para
///   cualquier pantalla o bloc.
/// - `BlocProvider<ThemeCubit>`: estado global del tema.
/// - `BlocProvider<PrivacyCubit>`: ocultar/mostrar importes (Reto 2).
/// - `BlocProvider<BalanceCubit>`: carga del resumen con estados (Reto 3).
///
/// `BlocBuilder` escucha el `ThemeCubit` y reconstruye `MaterialApp` cuando
/// cambia el modo claro/oscuro. Es el primer flujo evento → estado → interfaz
/// del curso.
class WalletApp extends StatelessWidget {
  const WalletApp({
    super.key,
    required this.firebaseStatus,
    this.themePreferences,
    this.initialThemeMode = ThemeMode.system,
    this.walletRepository,
  });

  final FirebaseStatus firebaseStatus;

  /// Almacenamiento del tema (Reto 1). Es opcional para que las pruebas de
  /// widget puedan construir la app sin `shared_preferences`.
  final ThemePreferences? themePreferences;

  /// Modo leído en `main()` antes de `runApp`.
  final ThemeMode initialThemeMode;

  /// Repositorio inyectable (Reto 3). Si es nulo se usa el de memoria.
  final WalletRepository? walletRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WalletRepository>(
          create: (_) => walletRepository ?? InMemoryWalletRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ThemeCubit(
              initialMode: initialThemeMode,
              preferences: themePreferences,
            ),
          ),
          // Reto 2: privacidad de importes, estado de presentación.
          BlocProvider(create: (_) => PrivacyCubit()),
          // Reto 3: el Cubit recibe el repositorio por constructor y la
          // carga empieza al crearlo.
          BlocProvider(
            create: (context) =>
                BalanceCubit(context.read<WalletRepository>())..load(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Wallet UNSAAC',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(themeState.seedColor),
              darkTheme: AppTheme.dark(themeState.seedColor),
              themeMode: themeState.mode,
              home: WalletHomePage(firebaseStatus: firebaseStatus),
            );
          },
        ),
      ),
    );
  }
}
