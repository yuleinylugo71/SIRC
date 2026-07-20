import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/ciudadano.dart';

class CiudadanoDetailScreen extends StatelessWidget {
  final Ciudadano ciudadano;

  const CiudadanoDetailScreen({
    super.key,
    required this.ciudadano,
  });

  @override
  Widget build(BuildContext context) {
    // Decodificar metadatos de auditoría de campos (LWW)
    Map<String, dynamic> metadatos = {};
    if (ciudadano.metadatosCampos != null) {
      try {
        metadatos = jsonDecode(ciudadano.metadatosCampos!);
      } catch (e) {
        // Ignorar
      }
    }

    final fechaNac = '${ciudadano.fechaNacimiento.day.toString().padLeft(2, '0')}/${ciudadano.fechaNacimiento.month.toString().padLeft(2, '0')}/${ciudadano.fechaNacimiento.year}';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Ciudadano'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.pushReplacement('/ciudadano-form', extra: {'ciudadano': ciudadano});
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
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.person, size: 48, color: Colors.blue.shade800),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${ciudadano.nombres} ${ciudadano.apellidos}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      valueColor: ciudadano.estadoSincronizacion == 'SINCRONIZADO' 
                          ? Colors.green.shade800 
                          : Colors.orange.shade800,
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
            if (metadatos.isNotEmpty) ...[
              const Text(
                'Marcas de Tiempo de Última Escritura (LWW)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: metadatos.entries.map((e) {
                      final fechaIso = e.value as String;
                      final fecha = DateTime.parse(fechaIso);
                      final fechaStr = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}:${fecha.second.toString().padLeft(2, '0')}';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.key.toUpperCase().replaceAll('_', ' '),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            Text(
                              fechaStr,
                              style: TextStyle(fontSize: 11, color: Colors.blue.shade900, fontFamily: 'monospace'),
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
          Icon(icon, size: 20, color: Colors.blue.shade800),
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
