import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../bloc/auth_provider.dart';
import '../bloc/sync_provider.dart';
import '../theme/sirc_theme.dart';

class MobileDashboardScreen extends ConsumerWidget {
  const MobileDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authEstado = ref.watch(authProvider);
    final syncEstado = ref.watch(syncProvider);

    if (authEstado is! AuthAuthenticated) {
      return const Scaffold(
        backgroundColor: Color(0xFFEAF4FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final db = ref.watch(appDatabaseProvider);
    final isAdmin = authEstado.rol.trim().toUpperCase() == 'ADMIN';
    final sincronizando = syncEstado is SyncLoading;

    ref.listen<SyncState>(syncProvider, (prev, next) {
      if (next is SyncSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.mensaje),
            backgroundColor: SircColors.success,
          ),
        );
      } else if (next is SyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.mensaje),
            backgroundColor: SircColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF4FF),
        titleSpacing: 16,
        title: const Text('SIRC'),
        actions: [
          IconButton(
            onPressed: () => context.push('/configuracion'),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          const Text(
            'Panel de inicio',
            style: TextStyle(
              color: SircColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Resumen local y accesos rapidos del sistema.',
            style: TextStyle(
              color: SircColors.inkLight,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<int>(
                  stream: db.ciudadanoDao.contarCiudadanos(
                    usuarioId: authEstado.usuarioId,
                    rol: authEstado.rol,
                  ),
                  builder: (context, snapshot) => _SummaryCard(
                    icon: Icons.groups_rounded,
                    label: 'Ciudadanos',
                    value: snapshot.hasError ? '--' : '${snapshot.data ?? 0}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StreamBuilder<int>(
                  stream: db.syncQueueDao.contarTareasPendientes(),
                  builder: (context, snapshot) => _SummaryCard(
                    icon: Icons.cloud_upload_rounded,
                    label: 'Pendientes',
                    value: snapshot.hasError ? '--' : '${snapshot.data ?? 0}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            icon: Icons.verified_user_rounded,
            label: 'Rol activo',
            value: authEstado.rol,
            wide: true,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: sincronizando
                ? null
                : () => ref.read(syncProvider.notifier).sincronizar(),
            icon: sincronizando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Icon(Icons.sync_rounded),
            label: Text(sincronizando ? 'Sincronizando' : 'Sincronizar datos'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: SircColors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Acciones rapidas',
            style: TextStyle(
              color: SircColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.groups_rounded,
            title: 'Ciudadanos',
            subtitle: 'Consultar registros guardados',
            onTap: () => context.push('/ciudadanos'),
          ),
          _ActionTile(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Registrar ciudadano',
            subtitle: 'Capturar nueva informacion',
            onTap: () => context.push('/ciudadano-form'),
          ),
          if (isAdmin)
            _ActionTile(
              icon: Icons.admin_panel_settings_rounded,
              title: 'Registrar agente',
              subtitle: 'Crear cuenta de trabajo de campo',
              onTap: () => context.push('/registrar-registrador'),
            ),
          if (isAdmin)
            _ActionTile(
              icon: Icons.badge_rounded,
              title: 'Agentes',
              subtitle: 'Administrar registradores',
              onTap: () => context.push('/agentes'),
            ),
        ],
      ),
      bottomNavigationBar: _MobileBottomNav(isAdmin: isAdmin),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool wide;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7E7FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: SircColors.blue, size: 23),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SircColors.ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SircColors.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD7E7FF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: SircColors.blue, size: 23),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: SircColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: SircColors.muted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: SircColors.muted,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final bool isAdmin;

  const _MobileBottomNav({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      height: 68,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFEAF4FF),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_filled),
          label: 'Inicio',
        ),
        const NavigationDestination(
          icon: Icon(Icons.people_alt_outlined),
          label: 'Ciudadanos',
        ),
        if (isAdmin)
          const NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            label: 'Agentes',
          ),
        const NavigationDestination(
          icon: Icon(Icons.menu_rounded),
          label: 'Mas',
        ),
      ],
      onDestinationSelected: (index) {
        if (index == 1) context.push('/ciudadanos');
        if (isAdmin && index == 2) context.push('/agentes');
        if ((!isAdmin && index == 2) || (isAdmin && index == 3)) {
          context.push('/configuracion');
        }
      },
    );
  }
}
