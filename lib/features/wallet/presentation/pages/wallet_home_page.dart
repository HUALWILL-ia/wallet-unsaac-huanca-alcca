import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/balance_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/firebase_status_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/movement_tile.dart';

/// Pantalla principal de Wallet UNSAAC.
///
/// Reto 3: ya no usa `FutureBuilder` ni llama al repositorio. Escucha al
/// `BalanceCubit` y dibuja un widget por cada estado sellado.
class WalletHomePage extends StatelessWidget {
  const WalletHomePage({super.key, required this.firebaseStatus});

  final FirebaseStatus firebaseStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Wallet UNSAAC',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
        actions: const [_ThemeModeButton(), SizedBox(width: 8)],
      ),
      body: BlocBuilder<BalanceCubit, BalanceState>(
        builder: (context, state) => switch (state) {
          BalanceInitial() || BalanceLoading() => const _LoadingView(),
          BalanceFailure(:final message) => _ErrorView(
            message: message,
            onRetry: () => context.read<BalanceCubit>().retry(),
          ),
          BalanceSuccess(:final summary) => _SummaryView(
            summary: summary,
            firebaseStatus: firebaseStatus,
          ),
        },
      ),
    );
  }
}

/// Contenido del estado de éxito: saldo, acciones y movimientos.
class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.summary, required this.firebaseStatus});

  final WalletSummary summary;
  final FirebaseStatus firebaseStatus;

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature se habilita en la Sesión 2.'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Reto 2: la lista escucha al PrivacyCubit; los datos del resumen
    // no cambian, solo cómo se muestran.
    return BlocBuilder<PrivacyCubit, PrivacyState>(
      builder: (context, privacy) => RefreshIndicator(
        onRefresh: () => context.read<BalanceCubit>().refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'Hola, estudiante UNSAAC',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Este es el resumen de tus finanzas en noviembre de 2026.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            BalanceCard(
              summary: summary,
              hideBalance: privacy.hidden,
              onToggleVisibility: () => context.read<PrivacyCubit>().toggle(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () =>
                        _showComingSoon(context, 'Registrar ingreso'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Ingreso'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showComingSoon(context, 'Registrar egreso'),
                    icon: const Icon(Icons.remove_rounded),
                    label: const Text('Egreso'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Últimos movimientos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      _showComingSoon(context, 'El historial completo'),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (summary.isEmpty)
              const _EmptyMovements()
            else
              for (final movement in summary.movements) ...[
                MovementTile(
                  movement: movement,
                  hideAmount: privacy.hidden,
                ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 12),
            FirebaseStatusCard(status: firebaseStatus),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Datos de demostración · Wallet UNSAAC 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(semanticsLabel: 'Cargando resumen'),
          SizedBox(height: 16),
          Text('Cargando tu resumen...'),
        ],
      ),
    );
  }
}

/// Botón del tema (Reto 1). El icono y el tooltip reflejan el modo actual y
/// anuncian el siguiente del ciclo claro → oscuro → sistema → claro.
class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton();

  static String _label(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'claro',
    ThemeMode.dark => 'oscuro',
    ThemeMode.system => 'del sistema',
  };

  static IconData _icon(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
    ThemeMode.system => Icons.brightness_auto_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return IconButton(
          tooltip:
              'Tema ${_label(state.mode)}. '
              'Cambiar a tema ${_label(state.nextMode)}',
          icon: Icon(_icon(state.mode)),
          onPressed: () => context.read<ThemeCubit>().toggle(),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Revisa la conexión y vuelve a intentarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMovements extends StatelessWidget {
  const _EmptyMovements();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            const Text('Todavía no registraste movimientos.'),
          ],
        ),
      ),
    );
  }
}
