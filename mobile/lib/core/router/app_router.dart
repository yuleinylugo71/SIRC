import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/ciudadano.dart';
import '../../presentation/screens/ciudadano_detail_screen.dart';
import '../../presentation/screens/ciudadano_form_screen.dart';
import '../../presentation/screens/ciudadanos_list_screen.dart';
import '../../presentation/screens/configuracion_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/registrar_registrador_screen.dart';
import '../../presentation/screens/agentes_list_screen.dart';

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
    } else {
      if (irALogin || irASplash) return '/dashboard';
    }
    return null;
  },
  routes: [
    // 1. Splash
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    // 2. Login
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // 3. Dashboard
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    // 4. Listado Ciudadanos
    GoRoute(
      path: '/ciudadanos',
      builder: (context, state) => const CiudadanosListScreen(),
    ),
    // 5. Formulario Ciudadano (Registrar / Editar)
    GoRoute(
      path: '/ciudadano-form',
      builder: (context, state) {
        final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
        final ciudadano = extra?['ciudadano'] as Ciudadano?;
        return CiudadanoFormScreen(ciudadano: ciudadano);
      },
    ),
    // 6. Detalle Ciudadano
    GoRoute(
      path: '/ciudadano-detalle',
      builder: (context, state) {
        final ciudadano = state.extra as Ciudadano;
        return CiudadanoDetailScreen(ciudadano: ciudadano);
      },
    ),
    // 7. Configuración
    GoRoute(
      path: '/configuracion',
      builder: (context, state) => const ConfiguracionScreen(),
    ),
    // 8. Registrar Registrador (Sólo Admin)
    GoRoute(
      path: '/registrar-registrador',
      builder: (context, state) => const RegistrarRegistradorScreen(),
    ),
    // 9. Listado de Agentes (Sólo Admin)
    GoRoute(
      path: '/agentes',
      builder: (context, state) => const AgentesListScreen(),
    ),
  ],
);
