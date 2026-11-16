import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/flaky_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';

void main() {
  group('Pantalla con BalanceCubit (Reto 3)', () {
    testWidgets('muestra carga y luego el saldo en el estado de éxito', (
      tester,
    ) async {
      await tester.pumpWidget(
        WalletApp(
          firebaseStatus: const FirebaseStatus.notConfigured(),
          walletRepository: InMemoryWalletRepository(
            latency: const Duration(milliseconds: 100),
          ),
        ),
      );

      expect(find.text('Cargando tu resumen...'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Cargando tu resumen...'), findsNothing);
      expect(find.text('S/ 1,274.60'), findsOneWidget);
      expect(find.text('Sueldo de prácticas'), findsOneWidget);
    });

    testWidgets('muestra el error y Reintentar recupera el saldo', (
      tester,
    ) async {
      await tester.pumpWidget(
        WalletApp(
          firebaseStatus: const FirebaseStatus.notConfigured(),
          walletRepository: FlakyWalletRepository(
            InMemoryWalletRepository(latency: Duration.zero),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No se pudo cargar el resumen.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Reintentar'), findsNothing);
      expect(find.text('S/ 1,274.60'), findsOneWidget);
    });
  });
}
