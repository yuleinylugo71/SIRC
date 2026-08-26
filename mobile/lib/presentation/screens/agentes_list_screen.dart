import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/usuario.dart';
import '../bloc/auth_provider.dart';
import '../theme/sirc_theme.dart';
import '../widgets/web_app_shell.dart';

class AgentesListScreen extends ConsumerStatefulWidget {
  const AgentesListScreen({super.key});

  @override
  ConsumerState<AgentesListScreen> createState() => _AgentesListScreenState();
}

class _AgentesListScreenState extends ConsumerState<AgentesListScreen> {
  bool _cargando = true;
  String? _error;
  List<Usuario> _agentes = [];

  @override
  void initState() {
    super.initState();
    _cargarAgentes();
  }

  Future<void> _cargarAgentes() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final authEstado = ref.read(authProvider);
    if (authEstado is! AuthAuthenticated) {
      setState(() {
        _cargando = false;
        _error = 'Sesión no activa';
      });
      return;
    }

    try {
      final repo = ref.read(usuarioRepositoryProvider);
      final lista = await repo.obtenerUsuarios(token: authEstado.token);
      if (mounted) {
        setState(() {
          _agentes = lista;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebContentPage(
        title: 'Agentes',
        subtitle: '${_agentes.length} usuarios registrados',
        actions: [
          ElevatedButton.icon(
            onPressed: () => context.go('/registrar-registrador'),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Registrar agente'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(178, 50),
              backgroundColor: SircColors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _cargando ? null : _cargarAgentes,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Actualizar'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(142, 50),
              foregroundColor: SircColors.blue,
              side: const BorderSide(color: SircColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
        child: _construirCuerpoWeb(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Agentes'),
        backgroundColor: SircColors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargando ? null : _cargarAgentes,
          ),
        ],
      ),
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpoWeb() {
    if (_cargando) {
      return const SizedBox(
        height: 360,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        height: 360,
        constraints: const BoxConstraints(maxWidth: 1120),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SircColors.border),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 56, color: SircColors.error),
              const SizedBox(height: 14),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: SircColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _cargarAgentes,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_agentes.isEmpty) {
      return Container(
        height: 360,
        constraints: const BoxConstraints(maxWidth: 1120),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SircColors.border),
        ),
        child: const Center(
          child: Text(
            'No hay agentes registrados.',
            style: TextStyle(
              color: SircColors.muted,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1120),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 980 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _agentes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 128,
            ),
            itemBuilder: (context, index) {
              final agente = _agentes[index];
              final esAdmin = agente.rol == 'ADMIN';

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SircColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: SircColors.blue.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          esAdmin ? SircColors.blue : SircColors.sky,
                      child: Icon(
                        esAdmin
                            ? Icons.admin_panel_settings_rounded
                            : Icons.person_outline_rounded,
                        color: esAdmin ? Colors.white : SircColors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agente.nombre ?? agente.correo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: SircColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            agente.correo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: SircColors.inkLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Rol: ${agente.rol}',
                            style: TextStyle(
                              color: esAdmin
                                  ? SircColors.blueDark
                                  : SircColors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'ID: ${agente.id.substring(0, 6)}...',
                      style: const TextStyle(
                        color: SircColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _cargarAgentes,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_agentes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.badge_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay agentes registrados.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarAgentes,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _agentes.length,
            itemBuilder: (context, index) {
              final agente = _agentes[index];
              final esAdmin = agente.rol == 'ADMIN';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor:
                        esAdmin ? SircColors.blueDark : SircColors.blue,
                    child: Icon(
                      esAdmin
                          ? Icons.admin_panel_settings
                          : Icons.person_outline,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    agente.nombre ?? agente.correo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Correo: ${agente.correo}'),
                      const SizedBox(height: 2),
                      Text(
                        'Rol: ${agente.rol}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              esAdmin ? SircColors.blueDark : SircColors.blue,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    'ID: ${agente.id.substring(0, 6)}...',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
