import 'package:flutter/material.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';

/// Opción de color semilla que ofrece el selector (Reto 4).
class SeedColorOption {
  const SeedColorOption(this.name, this.color);

  final String name;
  final Color color;
}

/// Colores disponibles. El granate institucional es el valor por defecto.
const List<SeedColorOption> kSeedColorOptions = [
  SeedColorOption('Granate UNSAAC', AppTheme.seed),
  SeedColorOption('Azul', Color(0xFF1565C0)),
  SeedColorOption('Verde', Color(0xFF2E7D32)),
  SeedColorOption('Naranja', Color(0xFFEF6C00)),
  SeedColorOption('Morado', Color(0xFF6A1B9A)),
];
