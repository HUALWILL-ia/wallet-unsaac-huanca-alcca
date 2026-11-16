import 'package:equatable/equatable.dart';

/// Estado de privacidad de los importes (Reto 2).
///
/// Es un estado de presentación: decide cómo se MUESTRAN los importes, no
/// cuáles son. Por eso no vive en el dominio ni en el repositorio.
class PrivacyState extends Equatable {
  const PrivacyState({this.hidden = false});

  final bool hidden;

  PrivacyState copyWith({bool? hidden}) =>
      PrivacyState(hidden: hidden ?? this.hidden);

  @override
  List<Object?> get props => [hidden];
}
