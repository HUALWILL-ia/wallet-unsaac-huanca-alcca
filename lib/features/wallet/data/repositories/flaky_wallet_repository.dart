import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';

/// Repositorio de demostración que falla las primeras [failures] llamadas y
/// luego delega en [delegate] (Reto 3).
///
/// Solo se usa para evidenciar en el emulador los estados de carga, error y
/// reintento: `flutter run --dart-define=SIMULAR_ERROR=true`.
class FlakyWalletRepository implements WalletRepository {
  FlakyWalletRepository(this.delegate, {this.failures = 1});

  final WalletRepository delegate;
  final int failures;
  int _calls = 0;

  @override
  Future<WalletSummary> loadSummary() async {
    _calls++;
    final summary = await delegate.loadSummary();
    if (_calls <= failures) {
      throw Exception('sin conexión (simulado)');
    }
    return summary;
  }
}
