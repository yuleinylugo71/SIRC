import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/ciudadano.dart';
import '../bloc/auth_provider.dart';
import '../bloc/ciudadanos_provider.dart';
import '../bloc/sync_provider.dart';
import '../theme/sirc_theme.dart';

class CiudadanosListScreen extends ConsumerStatefulWidget {
  const CiudadanosListScreen({super.key});

  @override
  ConsumerState<CiudadanosListScreen> createState() =>
      _CiudadanosListScreenState();
}

class _CiudadanosListScreenState extends ConsumerState<CiudadanosListScreen> {
  final _busquedaController = TextEditingController();
  bool _descargaInicialAdminSolicitada = false;

  @override
  void initState() {
    super.initState();
    // Carga inicial reactiva
    Future.microtask(() {
      final auth = ref.read(authProvider);
      if (auth is AuthAuthenticated) {
        ref
            .read(ciudadanosProvider.notifier)
            .cargarCiudadanos(usuarioId: auth.usuarioId, rol: auth.rol);
        if (auth.rol.trim().toUpperCase() == 'ADMIN' &&
            !_descargaInicialAdminSolicitada) {
          _descargaInicialAdminSolicitada = true;
          ref.read(syncProvider.notifier).sincronizar();
        }
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
        content: Text(
            '¿Deseas eliminar a ${ciudadano.nombres} ${ciudadano.apellidos}? Esta acción se registrará offline y se subirá luego.',
            style: const TextStyle(color: SircColors.inkLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(ciudadanosProvider.notifier)
                  .eliminarCiudadano(ciudadano.id);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SircColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
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
          child: Icon(Icons.cloud_done_rounded, color: SircColors.success, size: 20),
        );
      case 'CONFLICTO':
        return const Tooltip(
          message: 'Conflicto de versiones',
          child: Icon(Icons.cloud_off_rounded, color: SircColors.error, size: 20),
        );
      default:
        return const Tooltip(
          message: 'Cambio pendiente de subir',
          child: Icon(Icons.cloud_upload_rounded, color: SircColors.warning, size: 20),
        );
    }
  }

  Widget _buildCiudadanoCard(BuildContext context, Ciudadano c) {
    return Container(
      decoration: BoxDecoration(
        color: SircColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SircColors.border),
        boxShadow: [
          BoxShadow(
            color: SircColors.ink.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push('/ciudadano-detalle', extra: c);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: SircColors.blue.withOpacity(0.1),
                  foregroundColor: SircColors.blue,
                  radius: 24,
                  child: Text(
                    c.nombres.isNotEmpty ? c.nombres[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${c.nombres} ${c.apellidos}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: SircColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined,
                              size: 14, color: SircColors.muted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              c.documentoIdentidad,
                              style: const TextStyle(
                                  color: SircColors.inkLight, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (c.telefono != null && c.telefono!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 14, color: SircColors.muted),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                c.telefono!,
                                style: const TextStyle(
                                    color: SircColors.inkLight, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _obtenerIconoSincronizacion(c.estadoSincronizacion),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: SircColors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit_rounded,
                                color: SircColors.blue, size: 18),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              context.push('/ciudadano-form',
                                  extra: {'ciudadano': c});
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: SircColors.error.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete_rounded,
                                color: SircColors.error, size: 18),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            onPressed: () => _confirmarEliminacion(context, c),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(ciudadanosProvider);
    final authEstado = ref.watch(authProvider);

    // Escuchar notificaciones del estado para SnackBars
    ref.listen<CiudadanosEstado>(ciudadanosProvider, (prev, next) {
      if (next is CiudadanoOperacionExito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.mensaje),
            backgroundColor: SircColors.success,
          ),
        );
      } else if (next is CiudadanosError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.mensaje),
            backgroundColor: SircColors.error,
          ),
        );
      }
    });

    ref.listen<SyncState>(syncProvider, (prev, next) {
      if (next is SyncSuccess && authEstado is AuthAuthenticated) {
        ref.read(ciudadanosProvider.notifier).cargarCiudadanos(
              usuarioId: authEstado.usuarioId,
              rol: authEstado.rol,
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
      backgroundColor: SircColors.background,
      appBar: AppBar(
        title: const Text('Ciudadanos Registrados'),
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Buscador superior
          Container(
            color: SircColors.background,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: TextField(
                  controller: _busquedaController,
                  onChanged: (val) {
                    ref
                        .read(ciudadanosProvider.notifier)
                        .filtrarCiudadanos(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar por documento o nombre...',
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: SircColors.muted),
                    suffixIcon: _busquedaController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: SircColors.muted),
                            onPressed: () {
                              _busquedaController.clear();
                              ref
                                  .read(ciudadanosProvider.notifier)
                                  .filtrarCiudadanos('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: SircColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(color: SircColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(color: SircColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(
                          color: SircColors.blueAccent, width: 2),
                    ),
                  ),
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
                          Icon(Icons.person_search_rounded,
                              size: 72, color: SircColors.muted.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            _busquedaController.text.isEmpty
                                ? 'No hay ciudadanos registrados.'
                                : 'No se encontraron resultados.',
                            style: const TextStyle(
                                color: SircColors.muted, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 900;
                      final horizontalPadding = isWide ? 32.0 : 20.0;

                      if (isWide) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1180),
                            child: GridView.builder(
                              padding: EdgeInsets.fromLTRB(
                                  horizontalPadding, 0, horizontalPadding, 100),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 430,
                                mainAxisExtent: 132,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: lista.length,
                              itemBuilder: (context, index) =>
                                  _buildCiudadanoCard(context, lista[index]),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                            horizontalPadding, 0, horizontalPadding, 100),
                        itemCount: lista.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _buildCiudadanoCard(context, lista[index]),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/ciudadano-form');
        },
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Nuevo Ciudadano', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
