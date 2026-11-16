import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contrato para guardar y recuperar el modo de tema.
///
/// El `ThemeCubit` depende de esta abstracción y no de `SharedPreferences`
/// directamente: así se puede sustituir por un doble de prueba.
abstract interface class ThemePreferences {
  Future<ThemeMode> loadMode();

  Future<void> saveMode(ThemeMode mode);
}

/// Convierte el texto guardado en un [ThemeMode].
///
/// Si el valor es nulo o no se reconoce, devuelve [ThemeMode.system] en lugar
/// de lanzar una excepción.
ThemeMode themeModeFromName(String? name) => ThemeMode.values.firstWhere(
  (mode) => mode.name == name,
  orElse: () => ThemeMode.system,
);

/// Implementación con `shared_preferences`.
class SharedPrefsThemePreferences implements ThemePreferences {
  SharedPrefsThemePreferences(this._prefs);

  static const String storageKey = 'wallet.theme_mode';

  final SharedPreferences _prefs;

  /// Crea la instancia leyendo el almacenamiento del dispositivo.
  static Future<SharedPrefsThemePreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsThemePreferences(prefs);
  }

  @override
  Future<ThemeMode> loadMode() async {
    try {
      return themeModeFromName(_prefs.getString(storageKey));
    } catch (_) {
      // El valor guardado tiene un tipo inesperado (por ejemplo, un int):
      // se considera corrupto y se vuelve al modo del sistema.
      return ThemeMode.system;
    }
  }

  @override
  Future<void> saveMode(ThemeMode mode) async {
    await _prefs.setString(storageKey, mode.name);
  }
}
