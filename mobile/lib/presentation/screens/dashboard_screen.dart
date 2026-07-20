import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';
import '../bloc/auth_provider.dart';
import '../bloc/sync_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authEstado = ref.watch(authProvider);
    final syncEstado = ref.watch(syncProvider);

    // Evitar renderizados sin autenticación activa
    if (authEstado is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Escuchar cambios de la sincronización para lanzar SnackBar
    ref.listen<SyncState>(syncProvider, (prev, next) {
      if (next is SyncSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.mensaje),
            backgroundColor: Colors.green.shade800,
          ),
        );
      } else if (next is SyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.mensaje),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    });

    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control SIRC'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/configuracion'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bienvenida
            Card(
              elevation: 4,
              color: Colors.blue.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authEstado.rol == 'ADMIN' ? 'Bienvenido Administrador' : 'Bienvenido Registrador',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      authEstado.correo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone_android_outlined, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Disp ID: ${authEstado.dispositivoId.substring(0, 8)}...',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Métricas y KPI locales (Reactivos mediante Streams)
            const Text(
              'Estado de Persistencia Local',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Ciudadanos Totales
                Expanded(
                  child: StreamBuilder<int>(
                    stream: db.ciudadanoDao.contarCiudadanos(usuarioId: authEstado.usuarioId, rol: authEstado.rol),
                    builder: (context, snapshot) {
                      final total = snapshot.data ?? 0;
                      return _MetricCard(
                        titulo: 'Ciudadanos',
                        valor: '$total',
                        color: Colors.blue,
                        icono: Icons.people_alt_outlined,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Pendientes en Cola
                Expanded(
                  child: StreamBuilder<int>(
                    stream: db.syncQueueDao.contarTareasPendientes(),
                    builder: (context, snapshot) {
                      final pendientes = snapshot.data ?? 0;
                      return _MetricCard(
                        titulo: 'Por Sincronizar',
                        valor: '$pendientes',
                        color: pendientes > 0 ? Colors.orange : Colors.green,
                        icono: Icons.cloud_upload_outlined,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sincronización Manual
            ElevatedButton.icon(
              onPressed: syncEstado is SyncLoading
                  ? null
                  : () => ref.read(syncProvider.notifier).sincronizar(),
              icon: syncEstado is SyncLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.sync),
              label: Text(
                syncEstado is SyncLoading ? 'Sincronizando...' : 'Sincronizar Cambios',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

            // Accesos rápidos
            const Text(
              'Accesos Rápidos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _QuickLinkTile(
                  titulo: 'Ver Listado',
                  subtitulo: 'Lista de ciudadanos',
                  icono: Icons.list_alt,
                  color: Colors.blue.shade700,
                  onTap: () => context.push('/ciudadanos'),
                ),
                _QuickLinkTile(
                  titulo: 'Registrar',
                  subtitulo: 'Añadir ciudadano',
                  icono: Icons.person_add_alt_1,
                  color: Colors.purple.shade700,
                  onTap: () => context.push('/ciudadano-form'),
                ),
                if (authEstado.rol == 'ADMIN') ...[
                  _QuickLinkTile(
                    titulo: 'Registrar Agente',
                    subtitulo: 'Nuevo registrador',
                    icono: Icons.admin_panel_settings,
                    color: Colors.orange.shade800,
                    onTap: () => context.push('/registrar-registrador'),
                  ),
                  _QuickLinkTile(
                    titulo: 'Ver Agentes',
                    subtitulo: 'Lista de registradores',
                    icono: Icons.badge_outlined,
                    color: Colors.teal.shade700,
                    onTap: () => context.push('/agentes'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final MaterialColor color;
  final IconData icono;

  const _MetricCard({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icono, color: color.shade700),
                Text(
                  titulo,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              valor,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const _QuickLinkTile({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
