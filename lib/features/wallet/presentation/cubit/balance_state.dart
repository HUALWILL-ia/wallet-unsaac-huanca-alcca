import 'package:equatable/equatable.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';

/// Estados del resumen de la billetera (Reto 3).
///
/// La jerarquía es sellada (`sealed`): el compilador obliga a que la interfaz
/// trate los cuatro casos en un `switch`, así ninguno queda sin pantalla.
sealed class BalanceState extends Equatable {
  const BalanceState();

  @override
  List<Object?> get props => const [];
}

/// Todavía no se pidió nada al repositorio.
final class BalanceInitial extends BalanceState {
  const BalanceInitial();
}

/// Se está esperando la respuesta del repositorio.
final class BalanceLoading extends BalanceState {
  const BalanceLoading();
}

/// El repositorio respondió con un resumen.
final class BalanceSuccess extends BalanceState {
  const BalanceSuccess(this.summary);

  final WalletSummary summary;

  @override
  List<Object?> get props => [summary];
}

/// El repositorio falló; [message] se muestra al usuario.
final class BalanceFailure extends BalanceState {
  const BalanceFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
