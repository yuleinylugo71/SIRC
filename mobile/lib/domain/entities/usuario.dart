class Usuario {
  final String id;
  final String correo;
  final String? nombre;
  final String rol;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  Usuario({
    required this.id,
    required this.correo,
    this.nombre,
    required this.rol,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });
}
