class Ciudadano {
  final String id;
  final String documentoIdentidad;
  final String nombres;
  final String apellidos;
  final DateTime fechaNacimiento;
  final String? telefono;
  final String? correo;
  final String estadoSincronizacion; // PENDIENTE, SINCRONIZADO, CONFLICTO
  final String registradoPorUsuarioId;
  final String registradoEnDispositivoId;
  final int version;
  final String? metadatosCampos; // Metadatos de auditoría para Last Write Wins por campo (JSON)
  final DateTime createdAt;
  final DateTime updatedAt;

  Ciudadano({
    required this.id,
    required this.documentoIdentidad,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
    this.telefono,
    this.correo,
    required this.estadoSincronizacion,
    required this.registradoPorUsuarioId,
    required this.registradoEnDispositivoId,
    required this.version,
    this.metadatosCampos,
    required this.createdAt,
    required this.updatedAt,
  });
}
