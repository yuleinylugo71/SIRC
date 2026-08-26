import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/ciudadano.dart';
import '../../presentation/screens/agentes_list_screen.dart';
import '../../presentation/screens/ciudadano_detail_screen.dart';
import '../../presentation/screens/ciudadano_form_screen.dart';
import '../../presentation/screens/ciudadanos_list_screen.dart';
import '../../presentation/screens/configuracion_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/mobile_dashboard_screen.dart';
import '../../presentation/screens/registrar_registrador_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/widgets/web_app_shell.dart';

NoTransitionPage<void> _noTransitionPage(Widget child, {LocalKey? key}) {
  return NoTransitionPage<void>(key: key, child: child);
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final irALogin = state.matchedLocation == '/login';
    final irASplash = state.matchedLocation == '/';
    final estaAutenticado = token != null;

    if (!estaAutenticado) {
      if (irALogin || irASplash) return null;
      return '/login';
    }

    if (irALogin || irASplash) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _noTransitionPage(const SplashScreen(), key: state.pageKey),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          _noTransitionPage(const LoginScreen(), key: state.pageKey),
    ),
    ShellRoute(
      builder: (context, state, child) => WebRouteShell(
        location: state.matchedLocation,
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => _noTransitionPage(
            kIsWeb ? const DashboardScreen() : const MobileDashboardScreen(),
            key: state.pageKey,
          ),
        ),
        GoRoute(
          path: '/ciudadanos',
          pageBuilder: (context, state) => _noTransitionPage(
            const CiudadanosListScreen(),
            key: state.pageKey,
          ),
        ),
        GoRoute(
          path: '/ciudadano-form',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final ciudadano = extra?['ciudadano'] as Ciudadano?;
            return _noTransitionPage(
              CiudadanoFormScreen(ciudadano: ciudadano),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          path: '/ciudadano-detalle',
          pageBuilder: (context, state) {
            final ciudadano = state.extra as Ciudadano;
            return _noTransitionPage(
              CiudadanoDetailScreen(ciudadano: ciudadano),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          path: '/configuracion',
          pageBuilder: (context, state) => _noTransitionPage(
            const ConfiguracionScreen(),
            key: state.pageKey,
          ),
        ),
        GoRoute(
          path: '/registrar-registrador',
          pageBuilder: (context, state) => _noTransitionPage(
            const RegistrarRegistradorScreen(),
            key: state.pageKey,
          ),
        ),
        GoRoute(
          path: '/agentes',
          pageBuilder: (context, state) =>
              _noTransitionPage(const AgentesListScreen(), key: state.pageKey),
        ),
      ],
    ),
  ],
);
