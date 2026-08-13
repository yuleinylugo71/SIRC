import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';
import '../../data/datasources/local/daos/ciudadano_dao.dart';
import '../../domain/entities/ciudadano.dart';
import '../theme/sirc_theme.dart';

class CiudadanoDetailScreen extends ConsumerWidget {
  final Ciudadano ciudadano;

  const CiudadanoDetailScreen({
    super.key,
    required this.ciudadano,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Decodificar metadatos de auditoría de campos (LWW)
    Map<String, dynamic> metadatos = {};
    if (ciudadano.metadatosCampos != null) {
      try {
        metadatos = jsonDecode(ciudadano.metadatosCampos!);
      } catch (e) {
        // Ignorar
      }
    }

    final fechaNac =
        '${ciudadano.fechaNacimiento.day.toString().padLeft(2, '0')}/${ciudadano.fechaNacimiento.month.toString().padLeft(2, '0')}/${ciudadano.fechaNacimiento.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Ciudadano'),
        backgroundColor: SircColors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.pushReplacement('/ciudadano-form',
                  extra: {'ciudadano': ciudadano});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar e Info Principal
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: SircColors.sky,
                    child: const Icon(Icons.person,
                        size: 48, color: SircColors.blue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${ciudadano.nombres} ${ciudadano.apellidos}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Documento: ${ciudadano.documentoIdentidad}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tarjeta de Datos Personales
            const Text(
              'Datos Personales',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Fecha de Nacimiento',
                      value: fechaNac,
                      icon: Icons.calendar_month,
                    ),
                    const Divider(),
                    _DetailRow(
                      label: 'Teléfono',
                      value: ciudadano.telefono ?? 'No especificado',
                      icon: Icons.phone,
                    ),
                    const Divider(),
                    _DetailRow(
                      label: 'Correo Electrónico',
                      value: ciudadano.correo ?? 'No especificado',
                      icon: Icons.email,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tarjeta de Estado y Auditoría LWW (Detección de Conflictos)
            const Text(
              'Sincronización y Auditoría LWW',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'ID de Ciudadano (UUID)',
                      value: ciudadano.id,
                      icon: Icons.fingerprint,
                    ),
                    const Divider(),
                    _DetailRow(
                      label: 'Estado Sincronización',
                      value: ciudadano.estadoSincronizacion,
                      icon: Icons.cloud_queue,
                      valueColor:
                          ciudadano.estadoSincronizacion == 'SINCRONIZADO'
                              ? SircColors.blue
                              : SircColors.blueLight,
                    ),
                    const Divider(),
                    _DetailRow(
                      label: 'Versión del Registro',
                      value: 'v${ciudadano.version}',
                      icon: Icons.unfold_more,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Auditoría detallada por campos
            _VersionHistorySection(
              historialFuture: ref
                  .watch(ciudadanoDaoProvider)
                  .listarHistorialCiudadano(ciudadano.id),
            ),
            const SizedBox(height: 24),

            if (metadatos.isNotEmpty) ...[
              const Text(
                'Marcas de Tiempo de Última Escritura (LWW)',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: metadatos.entries.map((e) {
                      final fechaIso = e.value as String;
                      final fecha = DateTime.parse(fechaIso);
                      final fechaStr =
                          '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}:${fecha.second.toString().padLeft(2, '0')}';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.key.toUpperCase().replaceAll('_', ' '),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            Text(
                              fechaStr,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: SircColors.blueDark,
                                  fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VersionHistorySection extends StatelessWidget {
  final Future<List<CiudadanoHistorialLocal>> historialFuture;

  const _VersionHistorySection({required this.historialFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CiudadanoHistorialLocal>>(
      future: historialFuture,
      builder: (context, snapshot) {
        final historial = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Versiones anteriores',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (snapshot.hasError)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No se pudo cargar el historial: ${snapshot.error}',
                    style: const TextStyle(color: SircColors.error),
                  ),
                ),
              )
            else if (historial.isEmpty)
              Card(
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Este registro aun no tiene versiones anteriores guardadas.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
              ...historial.map((version) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: _VersionHistoryCard(version: version),
                );
              }),
          ],
        );
      },
    );
  }
}

class _VersionHistoryCard extends StatelessWidget {
  final CiudadanoHistorialLocal version;

  const _VersionHistoryCard({required this.version});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.history_rounded, color: SircColors.blue),
        title: Text(
          'Version v${version.version}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${version.motivo} - ${_formatearFechaHora(version.snapshotCreatedAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _DetailRow(
            label: 'Nombre completo',
            value: '${version.nombres} ${version.apellidos}',
            icon: Icons.person_outline,
          ),
          const Divider(),
          _DetailRow(
            label: 'Documento',
            value: version.documentoIdentidad,
            icon: Icons.badge_outlined,
          ),
          const Divider(),
          _DetailRow(
            label: 'Fecha de Nacimiento',
            value: _formatearFecha(version.fechaNacimiento),
            icon: Icons.calendar_month,
          ),
          const Divider(),
          _DetailRow(
            label: 'Telefono',
            value: version.telefono ?? 'No especificado',
            icon: Icons.phone,
          ),
          const Divider(),
          _DetailRow(
            label: 'Correo Electronico',
            value: version.correo ?? 'No especificado',
            icon: Icons.email,
          ),
          const Divider(),
          _DetailRow(
            label: 'Estado al guardar version',
            value: version.estadoSincronizacion,
            icon: Icons.cloud_queue,
          ),
        ],
      ),
    );
  }
}

String _formatearFecha(DateTime fecha) {
  return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
}

String _formatearFechaHora(DateTime fecha) {
  return '${_formatearFecha(fecha)} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: SircColors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? Colors.black87,
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
