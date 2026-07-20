import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/ciudadano.dart';
import '../bloc/auth_provider.dart';
import '../bloc/ciudadanos_provider.dart';

class CiudadanosListScreen extends ConsumerStatefulWidget {
  const CiudadanosListScreen({super.key});

  @override
  ConsumerState<CiudadanosListScreen> createState() => _CiudadanosListScreenState();
}

class _CiudadanosListScreenState extends ConsumerState<CiudadanosListScreen> {
  final _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carga inicial reactiva
    Future.microtask(() {
      final auth = ref.read(authProvider);
      if (auth is AuthAuthenticated) {
        ref.read(ciudadanosProvider.notifier).cargarCiudadanos(usuarioId: auth.usuarioId, rol: auth.rol);
      } else {
        ref.read(ciudadanosProvider.notifier).cargarCiudadanos();
      }
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _confirmarEliminacion(BuildContext context, Ciudadano ciudadano) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Deseas eliminar a ${ciudadano.nombres} ${ciudadano.apellidos}? Esta acción se registrará offline y se subirá luego.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(ciudadanosProvider.notifier).eliminarCiudadano(ciudadano.id);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _obtenerIconoSincronizacion(String estado) {
    switch (estado) {
      case 'SINCRONIZADO':
        return const Tooltip(
          message: 'Sincronizado en servidor',
          child: Icon(Icons.cloud_done_outlined, color: Colors.green),
        );
      case 'CONFLICTO':
        return const Tooltip(
          message: 'Conflicto de versiones',
          child: Icon(Icons.cloud_off_outlined, color: Colors.red),
        );
      default:
        return const Tooltip(
          message: 'Cambio pendiente de subir',
          child: Icon(Icons.cloud_upload_outlined, color: Colors.orange),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(ciudadanosProvider);

    // Escuchar notificaciones del estado para SnackBars
    ref.listen<CiudadanosEstado>(ciudadanosProvider, (prev, next) {
      if (next is CiudadanoOperacionExito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.mensaje),
            backgroundColor: Colors.green.shade800,
          ),
        );
      } else if (next is CiudadanosError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.mensaje),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ciudadanos Registrados'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Buscador superior
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _busquedaController,
              onChanged: (val) {
                ref.read(ciudadanosProvider.notifier).filtrarCiudadanos(val);
              },
              decoration: InputDecoration(
                labelText: 'Buscar por documento o nombre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busquedaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _busquedaController.clear();
                          ref.read(ciudadanosProvider.notifier).filtrarCiudadanos('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Listado reactivo
          Expanded(
            child: Builder(
              builder: (context) {
                if (estado is CiudadanosCargando) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (estado is CiudadanosCargados) {
                  final lista = estado.ciudadanosFiltrados;

                  if (lista.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            _busquedaController.text.isEmpty
                                ? 'No hay ciudadanos registrados.'
                                : 'No se encontraron resultados.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final c = lista[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          onTap: () {
                            // Navegar al detalle pasando la entidad
                            context.push('/ciudadano-detalle', extra: c);
                          },
                          title: Text(
                            '${c.nombres} ${c.apellidos}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Documento: ${c.documentoIdentidad}'),
                              if (c.telefono != null && c.telefono!.isNotEmpty)
                                Text('Teléfono: ${c.telefono}'),
                              const SizedBox(height: 4),
                              Text(
                                'Versión: ${c.version}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _obtenerIconoSincronizacion(c.estadoSincronizacion),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                onPressed: () {
                                  // Navegar al formulario para editar
                                  context.push('/ciudadano-form', extra: {'ciudadano': c});
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _confirmarEliminacion(context, c),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(child: Text('Inicializando listado...'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar al formulario de creación vacío
          context.push('/ciudadano-form');
        },
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
