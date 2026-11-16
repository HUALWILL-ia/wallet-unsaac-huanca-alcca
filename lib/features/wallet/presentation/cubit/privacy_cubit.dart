import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_state.dart';

/// Cubit que oculta o muestra los importes de la billetera (Reto 2).
///
/// No toca el repositorio ni las entidades: los datos siguen intactos en
/// memoria y solo cambia la forma en que la interfaz los presenta.
class PrivacyCubit extends Cubit<PrivacyState> {
  PrivacyCubit() : super(const PrivacyState());

  void toggle() => emit(state.copyWith(hidden: !state.hidden));

  void hide() => emit(state.copyWith(hidden: true));

  void show() => emit(state.copyWith(hidden: false));
}
