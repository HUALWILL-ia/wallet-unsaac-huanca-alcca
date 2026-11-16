import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/masked_amount.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/movement_tile.dart';

void main() {
  group('Saldo privado en la interfaz (Reto 2)', () {
    testWidgets('el ojo oculta y restaura saldo, ingresos y egresos', (
      tester,
    ) async {
      await tester.pumpWidget(
        const WalletApp(firebaseStatus: FirebaseStatus.notConfigured()),
      );
      await tester.pumpAndSettle();

      expect(find.text('S/ 1,274.60'), findsOneWidget);
      expect(find.text('S/ 1,770.00'), findsOneWidget);
      expect(find.text('S/ 495.40'), findsOneWidget);

      await tester.tap(find.byTooltip('Ocultar saldo'));
      await tester.pumpAndSettle();

      expect(find.text('S/ 1,274.60'), findsNothing);
      expect(find.text('S/ 1,770.00'), findsNothing);
      expect(find.text('S/ 495.40'), findsNothing);
      expect(find.text('+ S/ 1,200.00'), findsNothing);
      expect(find.text(kMaskedAmount), findsWidgets);
      expect(find.byTooltip('Mostrar saldo'), findsOneWidget);

      await tester.tap(find.byTooltip('Mostrar saldo'));
      await tester.pumpAndSettle();

      expect(find.text('S/ 1,274.60'), findsOneWidget);
      expect(find.text('+ S/ 1,200.00'), findsOneWidget);
      expect(find.byTooltip('Ocultar saldo'), findsOneWidget);
    });

    testWidgets('MovementTile enmascara el importe con hideAmount', (
      tester,
    ) async {
      final movement = Movement(
        id: 'tx-test',
        title: 'Pasajes',
        category: 'Transporte',
        amount: 48,
        type: MovementType.expense,
        date: DateTime(2026, 11, 6),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovementTile(movement: movement, hideAmount: true),
          ),
        ),
      );

      expect(find.text('- S/ 48.00'), findsNothing);
      expect(find.text(kMaskedAmount), findsOneWidget);
      expect(find.text('Pasajes'), findsOneWidget);
    });
  });
}
