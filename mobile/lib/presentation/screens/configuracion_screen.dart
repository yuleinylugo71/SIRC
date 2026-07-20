import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_provider.dart';
import '../bloc/sync_provider.dart';

class ConfiguracionScreen extends ConsumerWidget {
  const ConfiguracionScreen({super.key});

  void _confirmarCierreSesion(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Deseas cerrar tu sesión? Se eliminará la información temporal del dispositivo local.'),
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
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección Dispositivo
            const Text(
              'Dispositivo de Registro',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      colorValue: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sección Usuario
            const Text(
              'Información de Usuario',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Botón Cerrar Sesión
            OutlinedButton.icon(
              onPressed: () => _confirmarCierreSesion(context, ref),
              icon: const Icon(Icons.exit_to_app, color: Colors.red),
              label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
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
          Icon(icon, size: 20, color: Colors.blue.shade800),
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
