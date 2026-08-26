import 'package:flutter/foundation.dart';
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

    if (kIsWeb) {
      return _WebDashboard(
        authEstado: authEstado,
        syncEstado: syncEstado,
        isAdmin: isAdmin,
        ciudadanosStream: db.ciudadanoDao.contarCiudadanos(
          usuarioId: authEstado.usuarioId,
          rol: authEstado.rol,
        ),
        pendientesStream: db.syncQueueDao.contarTareasPendientes(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Color(0xFFEAF4FF))),
          Positioned(
            left: 16,
            right: 16,
            top: MediaQuery.of(context).padding.top + 18,
            bottom: 18,
            child: _MobileDashboardHome(
              isAdmin: isAdmin,
              rol: authEstado.rol,
              ciudadanosStream: db.ciudadanoDao.contarCiudadanos(
                usuarioId: authEstado.usuarioId,
                rol: authEstado.rol,
              ),
              pendientesStream: db.syncQueueDao.contarTareasPendientes(),
              onCitizens: () => context.push('/ciudadanos'),
              onRegisterCitizen: () => context.push('/ciudadano-form'),
              onRegisterAgent: () => context.push('/registrar-registrador'),
              onAgents: () => context.push('/agentes'),
              onSettings: () => context.push('/configuracion'),
            ),
          ),
        ],
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

class _MobileDashboardHome extends StatelessWidget {
  final bool isAdmin;
  final String rol;
  final Stream<int> ciudadanosStream;
  final Stream<int> pendientesStream;
  final VoidCallback onCitizens;
  final VoidCallback onRegisterCitizen;
  final VoidCallback onRegisterAgent;
  final VoidCallback onAgents;
  final VoidCallback onSettings;

  const _MobileDashboardHome({
    required this.isAdmin,
    required this.rol,
    required this.ciudadanosStream,
    required this.pendientesStream,
    required this.onCitizens,
    required this.onRegisterCitizen,
    required this.onRegisterAgent,
    required this.onAgents,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD7E7FF)),
                  ),
                  child: const Icon(
                    Icons.how_to_reg_rounded,
                    color: SircColors.blue,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SIRC',
                        style: TextStyle(
                          color: SircColors.blue,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Registro Ciudadano',
                        style: TextStyle(
                          color: SircColors.inkLight,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onSettings,
                  icon: const Icon(Icons.settings_rounded),
                  color: SircColors.inkLight,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panel de inicio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Resumen local y accesos rapidos del sistema.',
                    style: TextStyle(
                      color: Color(0xFFEAF4FF),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: ciudadanosStream,
                    builder: (context, snapshot) => _MobileSummaryCard(
                      icon: Icons.groups_rounded,
                      value: snapshot.hasError ? '--' : '${snapshot.data ?? 0}',
                      label: 'Ciudadanos',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<int>(
                    stream: pendientesStream,
                    builder: (context, snapshot) => _MobileSummaryCard(
                      icon: Icons.cloud_upload_rounded,
                      value: snapshot.hasError ? '--' : '${snapshot.data ?? 0}',
                      label: 'Pendientes',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MobileSummaryCard(
              icon: Icons.verified_user_rounded,
              value: rol,
              label: 'Rol activo',
              wide: true,
            ),
            const SizedBox(height: 22),
            const Text(
              'Acciones rapidas',
              style: TextStyle(
                color: SircColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            _MobileQuickAction(
              icon: Icons.groups_rounded,
              title: 'Ciudadanos',
              subtitle: 'Consultar registros guardados',
              onTap: onCitizens,
            ),
            _MobileQuickAction(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Registrar ciudadano',
              subtitle: 'Capturar nueva informacion',
              onTap: onRegisterCitizen,
            ),
            if (isAdmin)
              _MobileQuickAction(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Registrar agente',
                subtitle: 'Crear cuenta de trabajo de campo',
                onTap: onRegisterAgent,
              ),
            if (isAdmin)
              _MobileQuickAction(
                icon: Icons.badge_rounded,
                title: 'Agentes',
                subtitle: 'Administrar registradores',
                onTap: onAgents,
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileSummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool wide;

  const _MobileSummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E7FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: SircColors.blue, size: 22),
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
                const SizedBox(height: 4),
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

class _MobileQuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MobileQuickAction({
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
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD7E7FF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(14),
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

class _MobileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MobileInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: SircColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SircColors.sky,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: SircColors.blue, size: 24),
            ),
            const SizedBox(width: 14),
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
          ],
        ),
      ),
    );
  }
}

class _WebDashboard extends ConsumerWidget {
  final AuthAuthenticated authEstado;
  final SyncState syncEstado;
  final bool isAdmin;
  final Stream<int> ciudadanosStream;
  final Stream<int> pendientesStream;

  const _WebDashboard({
    required this.authEstado,
    required this.syncEstado,
    required this.isAdmin,
    required this.ciudadanosStream,
    required this.pendientesStream,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = syncEstado is SyncLoading;

    return Scaffold(
      backgroundColor: SircColors.background,
      body: Container(
        color: SircColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WebHeader(
                correo: authEstado.correo,
                rol: authEstado.rol,
                onSettings: () => context.go('/configuracion'),
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: SircColors.blue,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: SircColors.blue.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 18,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const SizedBox(
                      width: 560,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen operativo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Sistema de Informacion y Registro de Ciudadanos',
                            style: TextStyle(
                              color: Color(0xFFEFF6FF),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _WebSyncButton(loading: loading),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final useCompact = constraints.maxWidth < 850;
                  final cards = [
                    StreamBuilder<int>(
                      stream: ciudadanosStream,
                      builder: (context, snapshot) => _WebSummaryCard(
                        icon: Icons.people_alt_rounded,
                        label: 'Ciudadanos',
                        value: '${snapshot.data ?? 0}',
                        subtitle: 'Registros locales disponibles',
                      ),
                    ),
                    StreamBuilder<int>(
                      stream: pendientesStream,
                      builder: (context, snapshot) => _WebSummaryCard(
                        icon: Icons.cloud_upload_rounded,
                        label: 'Pendientes',
                        value: '${snapshot.data ?? 0}',
                        subtitle: 'Cambios por sincronizar',
                      ),
                    ),
                    _WebSummaryCard(
                      icon: Icons.verified_user_rounded,
                      label: 'Rol activo',
                      value: authEstado.rol,
                      subtitle: 'Perfil de la sesion actual',
                    ),
                  ];

                  if (useCompact) {
                    return Column(
                      children: cards
                          .map(
                            (card) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: card,
                            ),
                          )
                          .toList(),
                    );
                  }

                  return Row(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        Expanded(child: cards[i]),
                        if (i != cards.length - 1) const SizedBox(width: 16),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              const Text(
                'Acciones rapidas',
                style: TextStyle(
                  color: SircColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _WebActionsGrid(
                isAdmin: isAdmin,
                onCitizens: () => context.go('/ciudadanos'),
                onRegisterCitizen: () => context.go('/ciudadano-form'),
                onRegisterAgent: () => context.go('/registrar-registrador'),
                onAgents: () => context.go('/agentes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileDashboardHeader extends StatelessWidget {
  final VoidCallback onSettings;

  const _MobileDashboardHeader({required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: SircColors.sky,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SircColors.border),
          ),
          child: const Icon(
            Icons.how_to_reg_rounded,
            color: SircColors.blue,
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SIRC',
                style: TextStyle(
                  color: SircColors.blue,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Registro Ciudadano',
                style: TextStyle(
                  color: SircColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.more_vert_rounded),
          color: SircColors.inkLight,
        ),
      ],
    );
  }
}

class _MobileActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MobileActionButton({
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
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: SircColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: SircColors.sky,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: SircColors.blue, size: 24),
                ),
                const SizedBox(width: 14),
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
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WebSidebar extends StatelessWidget {
  final bool isAdmin;

  const _WebSidebar({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: SircColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: SircColors.sky,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: SircLogo(size: 30, showText: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SIRC',
                        style: TextStyle(
                          color: SircColors.blue,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Registro Ciudadano',
                        style: TextStyle(
                          color: SircColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _WebNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Inicio',
                selected: true,
                onTap: () => context.go('/dashboard'),
              ),
              _WebNavItem(
                icon: Icons.people_alt_rounded,
                label: 'Ciudadanos',
                onTap: () => context.go('/ciudadanos'),
              ),
              _WebNavItem(
                icon:
                    isAdmin ? Icons.badge_rounded : Icons.lock_outline_rounded,
                label: 'Agentes',
                enabled: isAdmin,
                onTap: isAdmin ? () => context.go('/agentes') : null,
              ),
              _WebNavItem(
                icon: Icons.settings_rounded,
                label: 'Configuracion',
                onTap: () => context.go('/configuracion'),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SircColors.sky,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SircColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_done_rounded,
                        color: SircColors.blue, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Web local activa',
                        style: TextStyle(
                          color: SircColors.inkLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _WebNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? SircColors.muted
        : selected
            ? SircColors.blue
            : SircColors.inkLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? SircColors.sky : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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

class _WebHeader extends StatelessWidget {
  final String correo;
  final String rol;
  final VoidCallback onSettings;

  const _WebHeader({
    required this.correo,
    required this.rol,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Panel de control',
                style: TextStyle(
                  color: SircColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Gestion local y sincronizacion',
                style: TextStyle(
                  color: SircColors.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SircColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: SircColors.sky,
                child: Icon(Icons.person_rounded,
                    color: SircColors.blue, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    correo,
                    style: const TextStyle(
                      color: SircColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    rol,
                    style: const TextStyle(
                      color: SircColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onSettings,
                icon: const Icon(Icons.settings_rounded),
                color: SircColors.inkLight,
                tooltip: 'Configuracion',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WebSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  const _WebSummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SircColors.border),
        boxShadow: [
          BoxShadow(
            color: SircColors.blue.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: SircColors.sky,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: SircColors.blue, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: SircColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SircColors.ink,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SircColors.inkLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _WebSyncButton extends ConsumerWidget {
  final bool loading;

  const _WebSyncButton({required this.loading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed:
          loading ? null : () => ref.read(syncProvider.notifier).sincronizar(),
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          : const Icon(Icons.sync_rounded),
      label: Text(loading ? 'Sincronizando' : 'Sincronizar datos'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: SircColors.blue,
        minimumSize: const Size(196, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _WebActionsGrid extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onCitizens;
  final VoidCallback onRegisterCitizen;
  final VoidCallback onRegisterAgent;
  final VoidCallback onAgents;

  const _WebActionsGrid({
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
        'Consultar registros locales',
        const [Color(0xFFEAF4FF), Color(0xFFD6EAFF)],
        onCitizens,
      ),
      _ActionItem(
        Icons.person_add_alt_1_rounded,
        'Registrar ciudadano',
        'Capturar nueva informacion',
        const [Color(0xFFEFF6FF), Color(0xFFDDEBFF)],
        onRegisterCitizen,
      ),
      if (isAdmin)
        _ActionItem(
          Icons.admin_panel_settings_rounded,
          'Registrar agente',
          'Crear usuarios de campo',
          const [Color(0xFFE8F7FF), Color(0xFFDCEBFF)],
          onRegisterAgent,
        ),
      if (isAdmin)
        _ActionItem(
          Icons.badge_rounded,
          'Ver agentes',
          'Administrar el equipo',
          const [Color(0xFFF3F8FF), Color(0xFFDCEEFF)],
          onAgents,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 760
                ? 2
                : 1;

        return GridView.builder(
          itemCount: actions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 156,
          ),
          itemBuilder: (context, index) {
            final item = actions[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: item.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, color: SircColors.blue, size: 30),
                      const Spacer(),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SircColors.ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SircColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AppHeader extends StatelessWidget {
  final VoidCallback onSettings;

  const _AppHeader({required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.68),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.85)),
            ),
            child: const SircLogo(size: 64, showText: false),
          ),
          const SizedBox(width: 10),
          const Spacer(),
          PressableCard(
            onTap: onSettings,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 44,
              height: 44,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: SircColors.blue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: SircColors.blue, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: SircColors.ink,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
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
      borderRadius: BorderRadius.circular(20),
      onTap:
          loading ? null : () => ref.read(syncProvider.notifier).sincronizar(),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SircColors.blue, SircColors.blueLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: SircColors.blue.withOpacity(0.24),
              blurRadius: 20,
              offset: const Offset(0, 10),
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
        'Captura nueva información',
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 650;
    final crossAxisCount = isDesktop ? 4 : 2;
    final childAspectRatio = isDesktop ? 1.08 : 1.1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: childAspectRatio,
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
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: item.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: SircColors.blue.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -24,
              child: Container(
                width: 68,
                height: 68,
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.86),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: SircColors.blue, size: 22),
                ),
                const Spacer(),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SircColors.ink,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SircColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Abrir',
                      style: TextStyle(
                        color: SircColors.blueDark,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: SircColors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 15),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 650;

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints:
                BoxConstraints(maxWidth: isDesktop ? 680 : double.infinity),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: 0,
              height: 65,
              backgroundColor: Colors.white,
              indicatorColor: SircColors.sky,
              surfaceTintColor: Colors.transparent,
              destinations: [
                const NavigationDestination(
                    icon: Icon(Icons.home_filled), label: 'Inicio'),
                const NavigationDestination(
                    icon: Icon(Icons.people_alt_outlined), label: 'Ciudadanos'),
                NavigationDestination(
                  icon: Icon(isAdmin
                      ? Icons.badge_outlined
                      : Icons.lock_outline_rounded),
                  label: 'Agentes',
                ),
                const NavigationDestination(
                    icon: Icon(Icons.menu_rounded), label: 'Más'),
              ],
              onDestinationSelected: (index) {
                if (index == 1) onCitizens();
                if (index == 2 && onAgents != null) onAgents!();
                if (index == 3) onMore();
              },
            ),
          ),
        ),
      ),
    );
  }
}
