import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemePreferences (Reto 1)', () {
    test('sin valor guardado devuelve ThemeMode.system', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPrefsThemePreferences.create();

      expect(await prefs.loadMode(), ThemeMode.system);
    });

    test('guarda y recupera el modo oscuro', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPrefsThemePreferences.create();

      await prefs.saveMode(ThemeMode.dark);

      final reopened = await SharedPrefsThemePreferences.create();
      expect(await reopened.loadMode(), ThemeMode.dark);
    });

    test('un texto no reconocido vuelve a system sin lanzar', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPrefsThemePreferences.storageKey: 'morado',
      });
      final prefs = await SharedPrefsThemePreferences.create();

      expect(await prefs.loadMode(), ThemeMode.system);
    });

    test('un valor de tipo incorrecto vuelve a system sin lanzar', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPrefsThemePreferences.storageKey: 42,
      });
      final prefs = await SharedPrefsThemePreferences.create();

      expect(await prefs.loadMode(), ThemeMode.system);
    });
  });

  group('ThemeCubit con persistencia (Reto 1)', () {
    test('cada cambio se guarda y sobrevive a un nuevo arranque', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPrefsThemePreferences.create();
      final cubit = ThemeCubit(preferences: prefs);

      await cubit.toggle(); // sistema → claro
      await cubit.toggle(); // claro → oscuro
      await cubit.close();

      // Simula cerrar y reabrir la app: se lee antes de crear el Cubit.
      final reopened = await SharedPrefsThemePreferences.create();
      final initialMode = await reopened.loadMode();
      final restored = ThemeCubit(
        initialMode: initialMode,
        preferences: reopened,
      );

      expect(restored.state.mode, ThemeMode.dark);
      await restored.close();
    });

    test('el ciclo completo vuelve a guardar system', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPrefsThemePreferences.create();
      final cubit = ThemeCubit(initialMode: ThemeMode.dark, preferences: prefs);

      await cubit.toggle(); // oscuro → sistema

      expect(cubit.state.mode, ThemeMode.system);
      expect(await prefs.loadMode(), ThemeMode.system);
      await cubit.close();
    });
  });
}
