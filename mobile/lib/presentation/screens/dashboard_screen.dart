import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../bloc/auth_provider.dart';
import '../bloc/sync_provider.dart';
import '../theme/sirc_theme.dart';
import '../widgets/sirc_background.dart';
import '../widgets/sirc_logo.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authEstado = ref.watch(authProvider);
    final syncEstado = ref.watch(syncProvider);

    if (authEstado is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ref.listen<SyncState>(syncProvider, (prev, next) {
      if (next is SyncSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.mensaje), backgroundColor: SircColors.success),
        );
      } else if (next is SyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.mensaje), backgroundColor: SircColors.error),
        );
      }
    });

    final db = ref.watch(appDatabaseProvider);
    final isAdmin = authEstado.rol == 'ADMIN';

    return Scaffold(
      body: SircBackground(
        child: SafeArea(
          child: Column(
            children: [
              _AppHeader(onSettings: () => context.push('/configuracion')),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Sistema de Informacion y Registro de Ciudadanos',
                        style: TextStyle(
                          color: SircColors.ink,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Gestion local y sincronizacion',
                        style: TextStyle(
                          color: SircColors.muted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: StreamBuilder<int>(
                              stream: db.ciudadanoDao.contarCiudadanos(
                                usuarioId: authEstado.usuarioId,
                                rol: authEstado.rol,
                              ),
                              builder: (context, snapshot) {
                                return _StatTile(
                                  icon: Icons.people_alt_rounded,
                                  value: '${snapshot.data ?? 0}',
                                  label: 'Ciudadanos',
                                  tint: const Color(0xFFEAF4FF),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StreamBuilder<int>(
                              stream: db.syncQueueDao.contarTareasPendientes(),
                              builder: (context, snapshot) {
                                return _StatTile(
                                  icon: Icons.cloud_upload_rounded,
                                  value: '${snapshot.data ?? 0}',
                                  label: 'Pendientes',
                                  tint: const Color(0xFFE9F7FF),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SyncButton(syncEstado: syncEstado),
                      const SizedBox(height: 28),
                      Row(
                        children: const [
                          Text(
                            'Acciones rapidas',
                            style: TextStyle(
                              color: SircColors.ink,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.touch_app_rounded,
                              color: SircColors.blue, size: 20),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _ActionGrid(
                        isAdmin: isAdmin,
                        onCitizens: () => context.push('/ciudadanos'),
                        onRegisterCitizen: () =>
                            context.push('/ciudadano-form'),
                        onRegisterAgent: () =>
                            context.push('/registrar-registrador'),
                        onAgents: () => context.push('/agentes'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        isAdmin: isAdmin,
        onCitizens: () => context.push('/ciudadanos'),
        onAgents: isAdmin ? () => context.push('/agentes') : null,
        onMore: () => context.push('/configuracion'),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  final VoidCallback onSettings;

  const _AppHeader({required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.68),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.85)),
            ),
            child: const SircLogo(size: 66, showText: false),
          ),
          const SizedBox(width: 10),
          const Spacer(),
          PressableCard(
            onTap: onSettings,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.78),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.more_vert_rounded,
                  color: SircColors.inkLight),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color tint;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: SircColors.blue.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: SircColors.blue, size: 24),
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              color: SircColors.ink,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: SircColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncButton extends ConsumerWidget {
  final SyncState syncEstado;

  const _SyncButton({required this.syncEstado});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = syncEstado is SyncLoading;

    return PressableCard(
      borderRadius: BorderRadius.circular(22),
      onTap:
          loading ? null : () => ref.read(syncProvider.notifier).sincronizar(),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SircColors.blue, SircColors.blueLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: SircColors.blue.withOpacity(0.25),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.sync_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              loading ? 'Sincronizando...' : 'Sincronizar datos',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onCitizens;
  final VoidCallback onRegisterCitizen;
  final VoidCallback onRegisterAgent;
  final VoidCallback onAgents;

  const _ActionGrid({
    required this.isAdmin,
    required this.onCitizens,
    required this.onRegisterCitizen,
    required this.onRegisterAgent,
    required this.onAgents,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        Icons.groups_rounded,
        'Ver ciudadanos',
        'Consulta registros locales',
        const [Color(0xFFEAF4FF), Color(0xFFD6EAFF)],
        onCitizens,
      ),
      _ActionItem(
        Icons.person_add_alt_1_rounded,
        'Registrar ciudadano',
        'Captura nueva informacion',
        const [Color(0xFFEFF6FF), Color(0xFFDDEBFF)],
        onRegisterCitizen,
      ),
      if (isAdmin)
        _ActionItem(
          Icons.admin_panel_settings_rounded,
          'Registrar agente',
          'Crea usuarios de campo',
          const [Color(0xFFE8F7FF), Color(0xFFDCEBFF)],
          onRegisterAgent,
        ),
      if (isAdmin)
        _ActionItem(
          Icons.badge_rounded,
          'Ver agentes',
          'Administra el equipo',
          const [Color(0xFFF3F8FF), Color(0xFFDCEEFF)],
          onAgents,
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.96,
      ),
      itemBuilder: (context, index) => _ActionCard(item: actions[index]),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionItem(
    this.icon,
    this.label,
    this.subtitle,
    this.gradient,
    this.onTap,
  );
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;

  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: item.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: SircColors.blue.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: -28,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.34),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.86),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(item.icon, color: SircColors.blue, size: 26),
                ),
                const Spacer(),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SircColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SircColors.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    const Text(
                      'Abrir',
                      style: TextStyle(
                        color: SircColors.blueDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: SircColors.blue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 17),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onCitizens;
  final VoidCallback? onAgents;
  final VoidCallback onMore;

  const _BottomNav({
    required this.isAdmin,
    required this.onCitizens,
    required this.onAgents,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      height: 74,
      backgroundColor: Colors.white,
      indicatorColor: SircColors.sky,
      surfaceTintColor: Colors.transparent,
      destinations: [
        const NavigationDestination(
            icon: Icon(Icons.home_filled), label: 'Inicio'),
        const NavigationDestination(
            icon: Icon(Icons.people_alt_outlined), label: 'Ciudadanos'),
        NavigationDestination(
          icon:
              Icon(isAdmin ? Icons.badge_outlined : Icons.lock_outline_rounded),
          label: 'Agentes',
        ),
        const NavigationDestination(
            icon: Icon(Icons.menu_rounded), label: 'Mas'),
      ],
      onDestinationSelected: (index) {
        if (index == 1) onCitizens();
        if (index == 2 && onAgents != null) onAgents!();
        if (index == 3) onMore();
      },
    );
  }
}
