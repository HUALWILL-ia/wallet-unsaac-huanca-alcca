import 'package:flutter/material.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_bootstrap.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/flaky_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';

/// Reto 3: `flutter run --dart-define=SIMULAR_ERROR=true` hace que la primera
/// carga falle y que la latencia sea mayor, para capturar carga, error y
/// reintento en el emulador.
const bool _simulateError = bool.fromEnvironment('SIMULAR_ERROR');

/// Punto de entrada de Wallet UNSAAC.
///
/// Orden obligatorio:
/// 1. `WidgetsFlutterBinding.ensureInitialized()` habilita los canales de
///    plataforma antes de tocar servicios nativos.
/// 2. La inicialización de Firebase se intenta antes de `runApp`, pero nunca
///    bloquea el arranque.
/// 3. Reto 1: se lee el modo de tema guardado ANTES de `runApp`, para que el
///    primer cuadro ya se pinte con el tema correcto (sin parpadeo).
/// 4. `runApp` construye el árbol de widgets.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseStatus = await FirebaseBootstrap.initialize();
  final themePreferences = await SharedPrefsThemePreferences.create();
  final initialThemeMode = await themePreferences.loadMode();
  final walletRepository = _simulateError
      ? FlakyWalletRepository(
          InMemoryWalletRepository(latency: const Duration(seconds: 3)),
        )
      : InMemoryWalletRepository();
  runApp(
    WalletApp(
      firebaseStatus: firebaseStatus,
      themePreferences: themePreferences,
      initialThemeMode: initialThemeMode,
      walletRepository: walletRepository,
    ),
  );
}
