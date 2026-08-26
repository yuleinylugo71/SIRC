import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/ciudadano.dart';
import '../bloc/auth_provider.dart';
import '../bloc/ciudadanos_provider.dart';
import '../bloc/sync_provider.dart';
import '../theme/sirc_theme.dart';
import '../widgets/sirc_logo.dart';

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

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        width: kIsWeb ? 520 : null,
      ),
    );
  }

  Widget _obtenerIconoSincronizacion(String estado) {
    switch (estado) {
      case 'SINCRONIZADO':
        return const Tooltip(
          message: 'Sincronizado en servidor',
          child: Icon(Icons.cloud_done_rounded,
              color: SircColors.success, size: 20),
        );
      case 'CONFLICTO':
        return const Tooltip(
          message: 'Conflicto de versiones',
          child:
              Icon(Icons.cloud_off_rounded, color: SircColors.error, size: 20),
        );
      default:
        return const Tooltip(
          message: 'Cambio pendiente de subir',
          child: Icon(Icons.cloud_upload_rounded,
              color: SircColors.warning, size: 20),
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

  Widget _buildWebScaffold(
    BuildContext context,
    CiudadanosEstado estado,
    AuthState authEstado,
  ) {
    return Scaffold(
      backgroundColor: SircColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CiudadanosWebHeader(
              total: estado is CiudadanosCargados
                  ? estado.ciudadanosFiltrados.length
                  : null,
              onNewCitizen: () => context.go('/ciudadano-form'),
            ),
            const SizedBox(height: 22),
            Container(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: TextField(
                controller: _busquedaController,
                onChanged: (val) {
                  ref.read(ciudadanosProvider.notifier).filtrarCiudadanos(val);
                  setState(() {});
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
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SircColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SircColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: SircColors.blueAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            _buildWebListBody(context, estado),
          ],
        ),
      ),
    );
  }

  Widget _buildWebListBody(BuildContext context, CiudadanosEstado estado) {
    if (estado is CiudadanosCargando) {
      return const SizedBox(
        height: 360,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (estado is! CiudadanosCargados) {
      return const SizedBox(
        height: 360,
        child: Center(child: Text('Inicializando listado...')),
      );
    }

    final lista = estado.ciudadanosFiltrados;
    if (lista.isEmpty) {
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
              Icon(
                Icons.person_search_rounded,
                size: 64,
                color: SircColors.muted.withOpacity(0.35),
              ),
              const SizedBox(height: 14),
              Text(
                _busquedaController.text.isEmpty
                    ? 'No hay ciudadanos registrados.'
                    : 'No se encontraron resultados.',
                style: const TextStyle(
                  color: SircColors.muted,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1200
            ? 3
            : constraints.maxWidth >= 760
                ? 2
                : 1;

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lista.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 142,
            ),
            itemBuilder: (context, index) =>
                _buildWebCiudadanoCard(context, lista[index]),
          ),
        );
      },
    );
  }

  Widget _buildWebCiudadanoCard(BuildContext context, Ciudadano c) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push('/ciudadano-detalle', extra: c),
        child: Ink(
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
                backgroundColor: SircColors.sky,
                foregroundColor: SircColors.blue,
                child: Text(
                  c.nombres.isNotEmpty ? c.nombres[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${c.nombres} ${c.apellidos}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SircColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _WebCitizenMeta(
                      icon: Icons.badge_outlined,
                      text: c.documentoIdentidad,
                    ),
                    if (c.telefono != null && c.telefono!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _WebCitizenMeta(
                        icon: Icons.phone_outlined,
                        text: c.telefono!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _obtenerIconoSincronizacion(c.estadoSincronizacion),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _WebIconAction(
                        icon: Icons.edit_rounded,
                        color: SircColors.blue,
                        onTap: () => context.push(
                          '/ciudadano-form',
                          extra: {'ciudadano': c},
                        ),
                      ),
                      const SizedBox(width: 8),
                      _WebIconAction(
                        icon: Icons.delete_rounded,
                        color: SircColors.error,
                        onTap: () => _confirmarEliminacion(context, c),
                      ),
                    ],
                  ),
                ],
              ),
            ],
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
        _mostrarMensaje(next.mensaje, SircColors.success);
      } else if (next is CiudadanosError) {
        _mostrarMensaje(next.mensaje, SircColors.error);
      }
    });

    ref.listen<SyncState>(syncProvider, (prev, next) {
      if (next is SyncSuccess && authEstado is AuthAuthenticated) {
        ref.read(ciudadanosProvider.notifier).cargarCiudadanos(
              usuarioId: authEstado.usuarioId,
              rol: authEstado.rol,
            );
      } else if (next is SyncError) {
        _mostrarMensaje(next.mensaje, SircColors.error);
      }
    });

    if (kIsWeb) {
      return _buildWebScaffold(context, estado, authEstado);
    }

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
                constraints: const BoxConstraints(maxWidth: 720),
                child: TextField(
                  controller: _busquedaController,
                  onChanged: (val) {
                    ref
                        .read(ciudadanosProvider.notifier)
                        .filtrarCiudadanos(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar por documento o nombre...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: SircColors.muted),
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
                              size: 72,
                              color: SircColors.muted.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            _busquedaController.text.isEmpty
                                ? 'No hay ciudadanos registrados.'
                                : 'No se encontraron resultados.',
                            style: const TextStyle(
                                color: SircColors.muted,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
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
                            constraints: const BoxConstraints(maxWidth: 720),
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
        label: const Text('Nuevo Ciudadano',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _CiudadanosWebSidebar extends StatelessWidget {
  final bool isAdmin;

  const _CiudadanosWebSidebar({required this.isAdmin});

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
              _CiudadanosWebNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Inicio',
                onTap: () => context.go('/dashboard'),
              ),
              _CiudadanosWebNavItem(
                icon: Icons.people_alt_rounded,
                label: 'Ciudadanos',
                selected: true,
                onTap: () => context.go('/ciudadanos'),
              ),
              _CiudadanosWebNavItem(
                icon:
                    isAdmin ? Icons.badge_rounded : Icons.lock_outline_rounded,
                label: 'Agentes',
                enabled: isAdmin,
                onTap: isAdmin ? () => context.go('/agentes') : null,
              ),
              _CiudadanosWebNavItem(
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
                        'Listado web activo',
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

class _CiudadanosWebNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _CiudadanosWebNavItem({
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

class _CiudadanosWebHeader extends StatelessWidget {
  final int? total;
  final VoidCallback onNewCitizen;

  const _CiudadanosWebHeader({
    required this.total,
    required this.onNewCitizen,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ciudadanos registrados',
              style: TextStyle(
                color: SircColors.ink,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              total == null
                  ? 'Gestion local y sincronizacion'
                  : '$total registros visibles',
              style: const TextStyle(
                color: SircColors.muted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: onNewCitizen,
          icon: const Icon(Icons.person_add_rounded),
          label: const Text('Nuevo ciudadano'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(190, 50),
            backgroundColor: SircColors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _WebCitizenMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WebCitizenMeta({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: SircColors.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SircColors.inkLight,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _WebIconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WebIconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.10),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
