import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_provider.dart';
import '../theme/sirc_theme.dart';
import 'sirc_logo.dart';

class WebRouteShell extends ConsumerWidget {
  final String location;
  final Widget child;

  const WebRouteShell({
    super.key,
    required this.location,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb) return child;

    final authEstado = ref.watch(authProvider);
    final isAdmin = authEstado is AuthAuthenticated &&
        authEstado.rol.trim().toUpperCase() == 'ADMIN';

    return Scaffold(
      backgroundColor: SircColors.background,
      body: Row(
        children: [
          _WebSideNav(
              selected: _selectedFromLocation(location), isAdmin: isAdmin),
          Expanded(child: child),
        ],
      ),
    );
  }

  String _selectedFromLocation(String location) {
    if (location.startsWith('/ciudadanos') ||
        location.startsWith('/ciudadano-detalle')) {
      return 'ciudadanos';
    }
    if (location.startsWith('/ciudadano-form')) return 'form';
    if (location.startsWith('/agentes') ||
        location.startsWith('/registrar-registrador')) {
      return 'agentes';
    }
    if (location.startsWith('/configuracion')) return 'configuracion';
    return 'dashboard';
  }
}

class WebAppShell extends StatelessWidget {
  final String selected;
  final bool isAdmin;
  final String title;
  final String subtitle;
  final List<Widget>? actions;
  final Widget child;

  const WebAppShell({
    super.key,
    required this.selected,
    required this.isAdmin,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SircColors.background,
      body: Row(
        children: [
          _WebSideNav(selected: selected, isAdmin: isAdmin),
          Expanded(
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: SircColors.ink,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: SircColors.muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (actions != null)
                          Wrap(spacing: 10, children: actions!),
                      ],
                    ),
                    const SizedBox(height: 22),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebContentPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;
  final Widget child;

  const WebContentPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SircColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: SircColors.ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: SircColors.muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (actions != null) Wrap(spacing: 10, children: actions!),
              ],
            ),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}

class _WebSideNav extends StatelessWidget {
  final String selected;
  final bool isAdmin;

  const _WebSideNav({required this.selected, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
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
                selected: selected == 'dashboard',
                onTap: () => context.go('/dashboard'),
              ),
              _WebNavItem(
                icon: Icons.people_alt_rounded,
                label: 'Ciudadanos',
                selected: selected == 'ciudadanos',
                onTap: () => context.go('/ciudadanos'),
              ),
              _WebNavItem(
                icon:
                    isAdmin ? Icons.badge_rounded : Icons.lock_outline_rounded,
                label: 'Agentes',
                selected: selected == 'agentes',
                enabled: isAdmin,
                onTap: isAdmin ? () => context.go('/agentes') : null,
              ),
              _WebNavItem(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Registrar',
                selected: selected == 'form',
                onTap: () => context.go('/ciudadano-form'),
              ),
              _WebNavItem(
                icon: Icons.settings_rounded,
                label: 'Configuracion',
                selected: selected == 'configuracion',
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
                        'Panel web activo',
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
