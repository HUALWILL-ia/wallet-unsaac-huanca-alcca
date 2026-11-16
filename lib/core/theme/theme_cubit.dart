import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

/// `Cubit` que gobierna el tema de la aplicación.
///
/// Reto 1: recorre los modos claro → oscuro → sistema → claro y guarda cada
/// cambio mediante [ThemePreferences]. La lectura inicial no ocurre aquí, sino
/// en `main()` antes de `runApp`, y llega como [initialMode].
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({ThemeMode initialMode = ThemeMode.system, this._preferences})
    : super(ThemeState(mode: initialMode));

  final ThemePreferences? _preferences;

  /// Avanza al siguiente modo del ciclo y lo guarda.
  Future<void> toggle() => setMode(state.nextMode);

  /// Emite el modo pedido y lo persiste de inmediato.
  Future<void> setMode(ThemeMode mode) async {
    emit(state.copyWith(mode: mode));
    await _preferences?.saveMode(mode);
  }

  Future<void> useSystemMode() => setMode(ThemeMode.system);

  /// Reto 4: cambia el color semilla sin tocar el modo claro/oscuro.
  void setSeedColor(Color color) => emit(state.copyWith(seedColor: color));
}
