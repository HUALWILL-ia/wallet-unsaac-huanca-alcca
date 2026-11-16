import 'package:flutter/material.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_bootstrap.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

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
  runApp(
    WalletApp(
      firebaseStatus: firebaseStatus,
      themePreferences: themePreferences,
      initialThemeMode: initialThemeMode,
    ),
  );
}
