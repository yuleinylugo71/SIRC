import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'data/datasources/local/sync_service.dart';
import 'presentation/bloc/auth_provider.dart';
import 'presentation/theme/sirc_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  // Inicializar demonio de sincronización automática de fondo
  final syncService = SyncService(
    procesarSincronizacionUseCase:
        container.read(procesarSincronizacionUseCaseProvider),
    connectivity: container.read(connectivityProvider),
  );
  syncService.inicializar();

  // Inicializar sesión antes de lanzar la interfaz (soporte para web refresh)
  await container.read(authProvider.notifier).inicializarSesion();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SircApp(),
    ),
  );
}

class SircApp extends StatelessWidget {
  const SircApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SIRC - Registro Ciudadano',
      debugShowCheckedModeBanner: false,
      theme: SircTheme.light(),
      routerConfig: appRouter,
    );
  }
}
