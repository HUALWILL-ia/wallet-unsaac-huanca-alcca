import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/flaky_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_state.dart';

/// Repositorio que siempre falla, para probar la rama de error sin emulador.
class _FailingRepository implements WalletRepository {
  @override
  Future<WalletSummary> loadSummary() async {
    throw Exception('sin conexión');
  }
}

/// Repositorio que cuenta cuántas veces se le consultó.
class _CountingRepository implements WalletRepository {
  _CountingRepository(this._delegate);

  final WalletRepository _delegate;
  int calls = 0;

  @override
  Future<WalletSummary> loadSummary() {
    calls++;
    return _delegate.loadSummary();
  }
}

void main() {
  InMemoryWalletRepository instantRepository() =>
      InMemoryWalletRepository(latency: Duration.zero);

  group('BalanceCubit (Reto 3)', () {
    test('el estado inicial es BalanceInitial', () {
      expect(
        BalanceCubit(instantRepository()).state,
        const BalanceInitial(),
      );
    });

    blocTest<BalanceCubit, BalanceState>(
      'éxito: emite Loading y luego Success con el saldo',
      build: () => BalanceCubit(instantRepository()),
      act: (cubit) => cubit.load(),
      expect: () => [
        const BalanceLoading(),
        isA<BalanceSuccess>().having(
          (state) => state.summary.balance,
          'balance',
          closeTo(1274.60, 0.001),
        ),
      ],
    );

    blocTest<BalanceCubit, BalanceState>(
      'fallo: emite Loading y luego Failure con mensaje',
      build: () => BalanceCubit(_FailingRepository()),
      act: (cubit) => cubit.load(),
      expect: () => const [
        BalanceLoading(),
        BalanceFailure(BalanceCubit.errorMessage),
      ],
    );

    late _CountingRepository counting;
    blocTest<BalanceCubit, BalanceState>(
      'reintento: tras un fallo vuelve a consultar y termina en éxito',
      setUp: () => counting = _CountingRepository(
        FlakyWalletRepository(instantRepository()),
      ),
      build: () => BalanceCubit(counting),
      act: (cubit) async {
        await cubit.load();
        await cubit.retry();
      },
      expect: () => [
        const BalanceLoading(),
        const BalanceFailure(BalanceCubit.errorMessage),
        const BalanceLoading(),
        isA<BalanceSuccess>(),
      ],
      verify: (_) => expect(counting.calls, 2),
    );

    blocTest<BalanceCubit, BalanceState>(
      'refresh recarga sin volver a mostrar la carga',
      build: () => BalanceCubit(instantRepository()),
      act: (cubit) async {
        await cubit.load();
        await cubit.refresh();
      },
      expect: () => [
        const BalanceLoading(),
        isA<BalanceSuccess>(),
        isA<BalanceSuccess>(),
      ],
    );

    test('no emite si se cierra mientras espera al repositorio', () async {
      final cubit = BalanceCubit(
        InMemoryWalletRepository(latency: const Duration(milliseconds: 50)),
      );
      final pending = cubit.load();
      await cubit.close();

      await expectLater(pending, completes);
      expect(cubit.state, const BalanceLoading());
    });
  });
}
