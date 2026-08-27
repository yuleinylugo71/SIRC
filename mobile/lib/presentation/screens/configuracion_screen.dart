import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';
import '../bloc/auth_provider.dart';
import '../bloc/sync_provider.dart';
import '../theme/sirc_theme.dart';

class ConfiguracionScreen extends ConsumerWidget {
  const ConfiguracionScreen({super.key});

  void _confirmarCierreSesion(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text(
            '¿Deseas cerrar tu sesión? Se eliminará la información temporal del dispositivo local.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarCambioContrasena(
    BuildContext context,
    WidgetRef ref,
    String token,
  ) async {
    final actualController = TextEditingController();
    final nuevaController = TextEditingController();
    final confirmarController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var guardando = false;
    var mostrarActual = false;
    var mostrarNueva = false;
    var mostrarConfirmar = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Cambiar contrasena'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: actualController,
                        obscureText: !mostrarActual,
                        decoration: InputDecoration(
                          labelText: 'Contrasena actual',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setDialogState(
                              () => mostrarActual = !mostrarActual,
                            ),
                            icon: Icon(mostrarActual
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa la contrasena actual';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nuevaController,
                        obscureText: !mostrarNueva,
                        decoration: InputDecoration(
                          labelText: 'Nueva contrasena',
                          prefixIcon: const Icon(Icons.password_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setDialogState(
                              () => mostrarNueva = !mostrarNueva,
                            ),
                            icon: Icon(mostrarNueva
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Minimo 6 caracteres';
                          }
                          if (value == actualController.text) {
                            return 'Usa una contrasena diferente';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmarController,
                        obscureText: !mostrarConfirmar,
                        decoration: InputDecoration(
                          labelText: 'Confirmar contrasena',
                          prefixIcon: const Icon(Icons.check_circle_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setDialogState(
                              () => mostrarConfirmar = !mostrarConfirmar,
                            ),
                            icon: Icon(mostrarConfirmar
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                        validator: (value) {
                          if (value != nuevaController.text) {
                            return 'Las contrasenas no coinciden';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      guardando ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          setDialogState(() => guardando = true);
                          try {
                            await ref
                                .read(usuarioRepositoryProvider)
                                .cambiarContrasena(
                                  contrasenaActual: actualController.text,
                                  nuevaContrasena: nuevaController.text,
                                  token: token,
                                );

                            if (!context.mounted) return;
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Contrasena actualizada correctamente.'),
                                backgroundColor: SircColors.success,
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            setDialogState(() => guardando = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                ),
                                backgroundColor: SircColors.error,
                              ),
                            );
                          }
                        },
                  icon: guardando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(guardando ? 'Guardando' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    actualController.dispose();
    nuevaController.dispose();
    confirmarController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authEstado = ref.watch(authProvider);

    if (authEstado is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Sesión inactiva.')),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sección Dispositivo
                const Text(
                  'Dispositivo de Registro',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _ConfigRow(
                          label: 'Código Único (UUID)',
                          value: authEstado.dispositivoId,
                          icon: Icons.phonelink_setup,
                        ),
                        const Divider(),
                        const _ConfigRow(
                          label: 'Estado de Licencia',
                          value: 'Activa (Dispositivo Exclusivo)',
                          icon: Icons.verified_user_outlined,
                          colorValue: SircColors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sección Usuario
                const Text(
                  'Información de Usuario',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _ConfigRow(
                          label: 'Usuario Activo',
                          value: authEstado.correo,
                          icon: Icons.person_outline,
                        ),
                        const Divider(),
                        _ConfigRow(
                          label: 'ID de Usuario',
                          value: authEstado.usuarioId,
                          icon: Icons.key_outlined,
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.password_rounded,
                              color: SircColors.blue),
                          title: const Text(
                            'Cambiar contrasena',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              const Text('Actualiza tu contrasena temporal'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _mostrarCambioContrasena(
                            context,
                            ref,
                            authEstado.token,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botón Sincronizar Cambios
                ElevatedButton.icon(
                  onPressed: () => ref.read(syncProvider.notifier).sincronizar(),
                  icon: const Icon(Icons.sync),
                  label: const Text('Forzar Sincronización Manual'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: SircColors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón Cerrar Sesión
                OutlinedButton.icon(
                  onPressed: () => _confirmarCierreSesion(context, ref),
                  icon: const Icon(Icons.exit_to_app, color: Colors.red),
                  label: const Text('Cerrar Sesión',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? colorValue;

  const _ConfigRow({
    required this.label,
    required this.value,
    required this.icon,
    this.colorValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: SircColors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorValue ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
