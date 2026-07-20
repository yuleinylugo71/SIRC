import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/usuario.dart';
import '../bloc/auth_provider.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Agentes'),
        backgroundColor: Colors.blue.shade900,
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _agentes.length,
        itemBuilder: (context, index) {
          final agente = _agentes[index];
          final esAdmin = agente.rol == 'ADMIN';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: esAdmin ? Colors.orange.shade800 : Colors.blue.shade700,
                child: Icon(
                  esAdmin ? Icons.admin_panel_settings : Icons.person_outline,
                  color: Colors.white,
                ),
              ),
              title: Text(
                agente.nombre ?? agente.correo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      color: esAdmin ? Colors.orange.shade900 : Colors.blue.shade900,
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
    );
  }
}
