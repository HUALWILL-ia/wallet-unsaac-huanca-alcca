import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_state.dart';

void main() {
  group('PrivacyCubit (Reto 2)', () {
    test('inicia con los importes visibles', () {
      expect(PrivacyCubit().state, const PrivacyState(hidden: false));
    });

    blocTest<PrivacyCubit, PrivacyState>(
      'toggle oculta los importes',
      build: PrivacyCubit.new,
      act: (cubit) => cubit.toggle(),
      expect: () => const [PrivacyState(hidden: true)],
    );

    blocTest<PrivacyCubit, PrivacyState>(
      'un segundo toggle vuelve a mostrarlos',
      build: PrivacyCubit.new,
      act: (cubit) {
        cubit.toggle();
        cubit.toggle();
      },
      expect: () => const [
        PrivacyState(hidden: true),
        PrivacyState(hidden: false),
      ],
    );

    blocTest<PrivacyCubit, PrivacyState>(
      'hide y show emiten el estado explícito sin duplicados',
      build: PrivacyCubit.new,
      act: (cubit) {
        cubit.hide();
        cubit.hide(); // Equatable evita una emisión repetida.
        cubit.show();
      },
      expect: () => const [
        PrivacyState(hidden: true),
        PrivacyState(hidden: false),
      ],
    );
  });
}
