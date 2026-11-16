import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/seed_colors.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

const Color _azul = Color(0xFF1565C0);

void main() {
  group('Color semilla (Reto 4)', () {
    test('hay al menos cuatro colores y el granate es el primero', () {
      expect(kSeedColorOptions.length, greaterThanOrEqualTo(4));
      expect(kSeedColorOptions.first.color, AppTheme.seed);
    });

    test('el estado inicia con el granate institucional', () {
      expect(const ThemeState().seedColor, AppTheme.seed);
    });

    test('seedColor participa en la igualdad del estado', () {
      expect(
        const ThemeState(seedColor: _azul),
        isNot(const ThemeState()),
      );
      expect(
        const ThemeState(seedColor: _azul),
        const ThemeState(seedColor: _azul),
      );
    });

    blocTest<ThemeCubit, ThemeState>(
      'setSeedColor cambia el color y conserva el modo',
      build: () => ThemeCubit(initialMode: ThemeMode.dark),
      act: (cubit) => cubit.setSeedColor(_azul),
      expect: () => const [
        ThemeState(mode: ThemeMode.dark, seedColor: _azul),
      ],
    );

    test('el primary del tema coincide con ColorScheme.fromSeed', () {
      for (final brightness in Brightness.values) {
        final expected = ColorScheme.fromSeed(
          seedColor: _azul,
          brightness: brightness,
        ).primary;
        final theme = brightness == Brightness.light
            ? AppTheme.light(_azul)
            : AppTheme.dark(_azul);

        expect(theme.colorScheme.primary, expected);
      }
      expect(
        AppTheme.light(_azul).colorScheme.primary,
        isNot(AppTheme.light().colorScheme.primary),
      );
    });

    testWidgets('el selector aplica el color a toda la app', (tester) async {
      await tester.pumpWidget(
        const WalletApp(firebaseStatus: FirebaseStatus.notConfigured()),
      );
      await tester.pumpAndSettle();

      MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
      final modeBefore = app().themeMode;

      await tester.tap(find.byTooltip('Cambiar color del tema'));
      await tester.pumpAndSettle();

      // Solo el granate está marcado al abrir.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await tester.tap(find.byTooltip('Azul'));
      await tester.pumpAndSettle();

      expect(
        app().theme!.colorScheme.primary,
        ColorScheme.fromSeed(seedColor: _azul).primary,
      );
      expect(
        app().darkTheme!.colorScheme.primary,
        ColorScheme.fromSeed(
          seedColor: _azul,
          brightness: Brightness.dark,
        ).primary,
      );
      expect(app().themeMode, modeBefore);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
