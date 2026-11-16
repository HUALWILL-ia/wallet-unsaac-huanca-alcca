import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_state.dart';

/// Cubit que carga el resumen de la billetera (Reto 3).
///
/// Reemplaza al `FutureBuilder`: la pantalla ya no llama al repositorio, solo
/// pide `load()`, `retry()` o `refresh()` y dibuja el estado que recibe.
class BalanceCubit extends Cubit<BalanceState> {
  BalanceCubit(this._repository) : super(const BalanceInitial());

  static const String errorMessage = 'No se pudo cargar el resumen.';

  final WalletRepository _repository;

  /// Carga inicial: muestra el indicador y luego éxito o fallo.
  Future<void> load() async {
    emit(const BalanceLoading());
    await _fetch();
  }

  /// Reintento tras un fallo: vuelve a consultar mostrando la carga.
  Future<void> retry() => load();

  /// Recarga desde el `RefreshIndicator`: mantiene los datos en pantalla
  /// (el propio RefreshIndicator ya muestra su indicador).
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    try {
      final summary = await _repository.loadSummary();
      if (isClosed) return;
      emit(BalanceSuccess(summary));
    } on Exception {
      if (isClosed) return;
      emit(const BalanceFailure(errorMessage));
    }
  }
}
